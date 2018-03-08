module ForemanMaintain
  module Concerns
    module BaseDatabase
      def configuration
        raise NotImplementedError
      end

      def query(sql, config = configuration)
        parse_csv(query_csv(sql, config))
      end

      def query_csv(sql, config = configuration)
        psql(%{COPY (#{sql}) TO STDOUT WITH CSV HEADER}, config)
      end

      def psql(query, config = configuration)
        execute("PGPASSWORD='#{config[%(password)]}' #{psql_db_connection_str(config)}",
                :stdin => query)
      end

      def ping(config = configuration)
        psql('SELECT 1 as ping', config)
      end

      def file_path_to_backup_db(config = configuration)
        dump_file_name = "#{config['database']}_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.dump"
        "#{db_backup_dir}/#{dump_file_name}"
      end

      def backup_db_command(backup_file_path, config = configuration)
        "runuser - postgres -c 'pg_dump -Fc #{config['database']} > #{backup_file_path}'"
      end

      def db_backup_dir
        raise NotImplementedError
      end

      def table_exist?(table_name)
        sql = <<-SQL
          SELECT EXISTS ( SELECT *
          FROM information_schema.tables WHERE table_name =  '#{table_name}' )
        SQL
        result = query(sql)
        return false if result.nil? || (result && result.empty?)
        result.first['exists'].eql?('t')
      end

      def delete_records_from_tbl_by_ids(tbl_name, rec_ids)
        quotize_rec_ids = rec_ids.map { |el| "'#{el}'" }.join(',')
        unless quotize_rec_ids.empty?
          psql(<<-SQL)
            BEGIN;
             DELETE FROM #{tbl_name} WHERE id IN (#{quotize_rec_ids});
            COMMIT;
          SQL
        end
      end

      private

      def psql_db_connection_str(config)
        "psql -d #{config['database']} -h #{config['host'] || 'localhost'} "\
        " -p #{config['port'] || '5432'} -U #{config['username']}"
      end
    end
  end
end
