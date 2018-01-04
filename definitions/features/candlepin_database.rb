class Features::CandlepinDatabase < ForemanMaintain::Feature
  CANDLEPIN_DB_CONFIG = '/etc/candlepin/candlepin.conf'.freeze

  include ForemanMaintain::Concerns::BaseDatabase

  metadata do
    label :candlepin_database

    confine do
      file_exists?(CANDLEPIN_DB_CONFIG)
    end
  end

  def configuration
    @configuration || load_configuration
  end

  def cpdb_help_output
    @cpdb_help_output || run_cpdb_help_cmd
  end

  def cpdb_help_for_option_check(option_name, parent_cmd = '')
    parent_cmd = '/usr/share/candlepin/cpdb' if parent_cmd.empty?
    help_cmd = "#{parent_cmd} --help |  grep -c '/\-/\-#{option_name} '"
    execute(help_cmd).strip.to_i
  end

  def wget_cpvalidation_and_execute
    directory_to_copy = prepare_for_dire_for_cpdb
    file_name = "#{directory_to_copy}/cpvalidation_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.zip"
    url_to_fetch_cpvalidation = 'https://github.com/candlepin/candlepinproject.org/raw/master/binaries/cpvalidation.zip'
    cmd = "wget -O #{file_name} #{url_to_fetch_cpvalidation}"
    execute!(cmd)
    execute!("unzip -o #{file_name} -d #{directory_to_copy}")
    linquibase_cmd_to_validate("#{directory_to_copy}/cpvalidation")
  end

  def execute_cpdb_validate_cmd
    main_cmd = cpdb_validate_cmd
    unless main_cmd.empty?
      execute!(main_cmd)
    end
  end

  private

  def load_configuration
    raw_config = File.read(CANDLEPIN_DB_CONFIG)
    full_config = Hash[raw_config.scan(/(^[^#\n][^=]*)=(.*)/)]
    uri = %r{://(([^/:]*):?([^/]*))/(.*)}.match(full_config['org.quartz.dataSource.myDS.URL'])
    @configuration = {
      'username' => full_config['org.quartz.dataSource.myDS.user'],
      'password' => full_config['org.quartz.dataSource.myDS.password'],
      'database' => uri[4],
      'host' => uri[2],
      'port' => uri[3] || '5432',
      'driver' => full_config['org.quartz.dataSource.myDS.driver'],
      'url' => full_config['org.quartz.dataSource.myDS.URL']
    }
  end

  def linquibase_cmd_to_validate(cpdb_validation_path)
    cmd = "liquibase --classpath=/usr/share/java/postgresql-jdbc.jar:#{cpdb_validation_path}" \
          " --changeLogFile=#{cpdb_validation_path}/changelog-validate.xml" \
          " --driver=#{configuration['driver']}" \
          " --url=#{configuration['url']}" \
          " --username=#{configuration['username']}" \
          " --password='#{configuration[%(password)]}'" \
          ' --logLevel=debug migrate'
    execute!(cmd)
  end

  def prepare_for_dire_for_cpdb
    parent_dir = ForemanMaintain.config.backup_dir
    dir = "#{parent_dir}/cpdb-validation-folders"
    execute("mkdir -p #{dir}")
    dir
  end

  def cpdb_validate_cmd
    return '' if cbdb_help_for_option_check('validate') == 0
    cmd = '/usr/share/candlepin/cpdb --validate'
    return cmd if cbdb_help_for_option_check('verbose', cmd) == 0
    cmd += ' --verbose'
    cmd
  end
end
