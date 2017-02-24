require 'foreman_maintain/concerns/utility/disk_type'
require 'foreman_maintain/concerns/utility/disk_io'
require 'foreman_maintain/concerns/utility/file_io'

module ForemanMaintain
  module Concerns
    module Utility
      MIN_SPEED_MBPS = 80

      def self.included(klass)
        klass.extend(self)
      end

      def io_pulp
        @io_pulp ||= DiskType.check('/var/lib/pulp')
      end

      def io_mongodb
        @io_mongodb ||= DiskType.check('/var/lib/mongodb')
      end

      def io_pgsql
        @io_pgsql ||= DiskType.check('/var/lib/pgsql')
      end

      def speed
        io.speed
      end

      def speed_pulp
        io_pulp.speed
      end

      def speed_mongodb
        io_mongodb.speed
      end

      def speed_pgsql
        io_pgsql.speed
      end

      def error_message
        'Slow disk detected. Disk IO should be atleast 80MB/sec'
      end
    end
  end
end
