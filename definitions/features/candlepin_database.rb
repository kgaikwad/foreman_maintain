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

  def validate_available_in_cpdb?
    check_option_using_cpdb_help('validate')
  end

  def check_option_using_cpdb_help(option_name, parent_cmd = '')
    parent_cmd = '/usr/share/candlepin/cpdb' if parent_cmd.empty?
    help_cmd = "#{parent_cmd} --help |  grep -c '\\-\\-#{option_name} '"
    execute?(help_cmd)
  end

  def execute_cpdb_validate_cmd
    main_cmd = cpdb_validate_cmd
    return [true, nil] if main_cmd.empty?
    main_cmd += format_shell_args(
      '-u' => configuration['username'], '-p' => configuration[%(password)]
    )
    response_on_execute(main_cmd, :hidden_patterns => [configuration['password']])
  end

  def db_backup_dir
    @db_backup_dir ||= File.expand_path(
      ForemanMaintain.config.db_backup_directories[:candlepin]
    )
  end

  def start_on_db_backup
    backup_file_path = file_path_to_backup_db
    backup_cmd = backup_db_command(backup_file_path)
    execute!(backup_cmd)
    puts "\n Note: Candlepin DB backup file path - #{backup_file_path}"
    puts "\n In case of any exception, use above dump file to restore DB."
  end

  def env_content_ids_with_null_content
    sql = <<-SQL
      SELECT ec.id
      FROM cp_env_content ec
      LEFT JOIN cp_content c ON ec.contentid = c.id WHERE c.id IS NULL
    SQL
    query(sql).map { |r| r['id'] }
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

  def cpdb_validate_cmd
    return '' unless check_option_using_cpdb_help('validate')
    cmd = '/usr/share/candlepin/cpdb --validate'
    return cmd unless check_option_using_cpdb_help('verbose', cmd)
    cmd += ' --verbose'
    cmd
  end
end
