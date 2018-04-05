require File.expand_path('../test_helper', File.dirname(__FILE__))

module DefinitionsTestHelper
  include ForemanMaintain::Concerns::Finders

  def detector
    @detector ||= ForemanMaintain.detector
  end

  def feature_class(feature_label)
    feature_class = detector.send(:autodetect_features)[feature_label.to_sym].first
    raise "Feature #{feature_label} not present in autodetect features" unless feature_class
    feature_class
  end

  def assume_feature_present(feature_label, stubs = nil)
    feature_class = self.feature_class(feature_label)
    feature_class.stubs(:present? => true)
    feature_class.any_instance.stubs(stubs) if stubs
    yield feature_class if block_given?
  end

  def assume_feature_absent(feature_label)
    feature_class = self.feature_class(feature_label)
    feature_class.stubs(:present? => false)
  end

  def log_reporter
    @log_reporter
  end

  def reset_reporter
    @log_reporter = Support::LogReporter.new
    ForemanMaintain.stubs(:reporter).returns(@log_reporter)
  end

  def run_step(step)
    ForemanMaintain::Runner::Execution.new(step, @log_reporter).tap(&:run)
  end

  def assert_stdout(expected_output)
    assert_equal expected_output.strip, log_reporter.output.strip
  end

  alias run_check run_step
  alias run_procedure run_step

  def mock_with_spinner(definition)
    mock_spinner = MiniTest::Mock.new
    mock_spinner.expect(:update, nil)

    definition.stubs(:with_spinner).returns(mock_spinner)
    mock_spinner
  end

  def stub_systemctl_calls(services, action)
    services.each do |service|
      Features::Service.
        any_instance.
        stubs(:perform_action_on_service).
        with(action, service).
        returns(true)
    end
  end

  def version(version_str)
    ForemanMaintain::Concerns::SystemHelpers::Version.new(version_str)
  end

  def setup
    reset_reporter
  end

  def teardown
    detector.refresh
  end

  # given the current feature assumptions (see assume_feature_present and
  # assume_feature_absent), assert the scenario with given filter is considered
  # present
  def assert_scenario(filter)
    scenario = find_scenarios(filter).first
    assert scenario, "Expected the scenario #{filter} to be present"
    scenario
  end

  # given the current feature assumptions (see assume_feature_present and
  # assume_feature_absent), assert the scenario with given filter is considered
  # absent
  def refute_scenario(filter)
    scenario = find_scenarios(filter).first
    refute scenario, "Expected the scenario #{filter} to be absent"
  end

  def hammer_config_dirs(dirs)
    Features::Hammer.any_instance.stubs(:config_directories).returns(dirs)
  end

  def installer_config_dir(dirs)
    Features::Installer.any_instance.stubs(:config_directory).returns(dirs)
  end

  def stub_foreman_proxy_config
    settings_file = '/etc/foreman-proxy/settings.yml'
    Features::ForemanProxy.any_instance.stubs(
      :lookup_dhcpd_config_file => '/etc/dhcp/dhcpd.conf',
      :lookup_into => settings_file,
      :settings_file => settings_file,
      :load_proxy_settings => {},
      :dhcpd_conf_exist? => true,
      :features => ['dhcp']
    )
  end

  def mock_installer_package(package)
    Features::Installer.any_instance.stubs(:find_package).returns(nil)
    Features::Installer.any_instance.stubs(:find_package).with do |args|
      args == package
    end.returns(package)
  end
end

TEST_DIR = File.dirname(__FILE__)
CONFIG_FILE = File.join(TEST_DIR, 'config/foreman_maintain.yml.test').freeze

ForemanMaintain.setup
