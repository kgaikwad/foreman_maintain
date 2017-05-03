class Features::ForemanProxy < ForemanMaintain::Feature
  metadata do
    label :foreman_proxy
  end

  attr_reader :dhcpd_conf_file, :cert_path

  def initialize
    @dhcpd_conf_file = '/etc/dhcp/dhcpd.conf'
    @cert_path = ForemanMaintain.config.foreman_proxy_cert_path
  end

  def valid_dhcp_configs?
    dhcp_req_pass? && !syntax_error_exists?
  end

  private

  def dhcp_req_pass?
    cmd = "curl -ks --cert #{cert_path}/client_cert.pem \
                    --key #{cert_path}/client_key.pem \
                    --cacert #{cert_path}/proxy_ca.pem https://$(hostname):9090/dhcp"
    output_string = execute(cmd)
    result = json_parse(output_string)
    success = true
    unless result
      success = false
      puts "Curl requrest failed to create DHCP Settings: #{output_string}"
    end
    success
  end

  def syntax_error_exists?
    cmd = "dhcpd -t -cf #{dhcpd_conf_file}"
    output = execute(cmd)
    is_error = output.include?('Configuration file errors encountered')
    if is_error
      puts "\nFound syntax error in file #{dhcpd_conf_file}:"
      puts output
    end
    is_error
  end
end
