module Checks::Repositories
  class Validate < ForemanMaintain::Check
    metadata do
      description 'Validate availability of repositories'
      preparation_steps do
        Procedures::Packages::Install.new(:packages => [ForemanMaintain::Utils::Facter.package])
      end

      confine do
        feature(:downstream)
      end

      param :version,
            'Version for which repositories needs to be validated',
            :required => true

      manual_detection
    end

    def run
      with_spinner("Validating availability of repositories for #{@version}") do |spinner|
        absent_repos = feature(:downstream).absent_repos(@version)
        unless absent_repos.empty?
          spinner.update('Some repositories missing, calling `subscription-manager refresh`')
          feature(:downstream).rhsm_refresh
          absent_repos = feature(:downstream).absent_repos(@version)
        end
        unless absent_repos.empty?
          fail!(
            "Following repositories are not available on your system: #{absent_repos.join(', ')}"
          )
        end
      end
    end
  end
end
