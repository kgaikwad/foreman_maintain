class Checks::HostsEntryVerify < ForemanMaintain::Check
  metadata do
    label :downstream
    description 'Check for verifying FQDN entry in hosts file'
    tags :default

    confine do
      file_exists?('/etc/hosts')
      file_exists?('/etc/hostname')
    end
  end

  def run
    etc_hostname_val = fetch_etc_hostname
    hosts_entry_values = []
    unless etc_hostname_val.eql?('localhost')
      hosts_entry_values = fetch_etc_hosts_entry_by_ip
      if hosts_entry_values.length
        fqdn_entry = hosts_entry_values[1]
        alias_entry = hosts_entry_values[2]
        if alias_entry && !fqdn_entry.include?(alias_entry)
          raise ForemanMaintain::Error::Warn, warn_msg_for_hosts_entry(alias_entry, fqdn_entry)
        end
      end
    end
  end

  private

  def warn_msg_for_hosts_entry(alias_name, hostname_value)
    <<-EOF
    Please verify FQDN and alias are configured correctly in /etc/hosts.
    If not, this may lead to incorrect reverse resolution.
    It should be in below format
      IP_ADDRESS FQDN ALIAS1 ALIAS2 ...

    Currently, it is showing value for FQDN -> '#{hostname_value}' &
    alias1 -> '#{alias_name}'.
    Please follow the correct nomenclature while doing network configurations.
    EOF
  end

  def find_fqdn_in_alias(hostname_val)
    alias_list = host_alias_names
    arr = alias_list.select { |val| val.eql?(hostname_val) }
    arr.uniq!
    arr[0]
  end

  def fetch_etc_hosts_entry_by_ip
    ip_address = fetch_server_ip
    output = execute(cmd_to_fetch_host_entry(ip_address)).gsub(/#.*/, '')
    output.strip!
    output.empty? ? [] : output.split(' ')
  end

  def cmd_to_fetch_host_entry(ip_address)
    "awk '/^[[:space:]]*($|#)/{next} /#{ip_address}/{print $1, $2, $3; exit}' /etc/hosts"
  end
end
