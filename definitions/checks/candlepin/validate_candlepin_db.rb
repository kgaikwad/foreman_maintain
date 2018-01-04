module Checks::Candlepin
  class ValidateCandlepinDb < ForemanMaintain::Check
    metadata do
      description 'Check to validate candlepin database'
      tags :pre_upgrade

      preparation_steps { Procedures::Packages::Install.new(:packages => %w[unzip wget]) }

      confine do
        feature(:candlepin)
      end
    end

    def run
      execute_candlepin_db_validations
      output = execute('echo $?').strip.to_i
      assert(output == 0, 'Failed candlepin db validation')
    end

    private

    def execute_candlepin_db_validations
      if feature(:candlepin_database).cpdb_help_for_option_check('validate') == 0
        feature(:candlepin_database).wget_cpvalidation_and_execute
      else
        feature(:candlepin_database).execute_cpdb_validate_cmd
      end
    end
  end
end
