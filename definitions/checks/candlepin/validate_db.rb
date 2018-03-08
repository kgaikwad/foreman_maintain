module Checks::Candlepin
  class ValidateDb < ForemanMaintain::Check
    metadata do
      description 'Check to validate candlepin database'
      tags :pre_upgrade

      confine do
        feature(:candlepin_database) && feature(:candlepin_database).validate_available_in_cpdb?
      end
    end

    def run
      result, result_msg = feature(:candlepin_database).execute_cpdb_validate_cmd
      if result_msg
        assert(result,
               result_msg,
               :next_steps =>
                 [Procedures::Candlepin::DeleteOrphanedRecordsFromEnvContent.new,
                  Procedures::KnowledgeBaseArticle.new(:doc_name => :fix_cpdb_validate_failure)])
      end
    end
  end
end
