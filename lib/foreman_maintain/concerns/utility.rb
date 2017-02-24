require 'foreman_maintain/concerns/utility/device'
require 'foreman_maintain/concerns/utility/disk_type'
require 'foreman_maintain/concerns/utility/disk_io'
require 'foreman_maintain/concerns/utility/file_io'

module ForemanMaintain
  module Concerns
    module Utility
      include Logger
      MIN_SPEED_MBPS = 80
      DIRECTORY_NAMES = ['/var/lib/pulp', '/var/lib/mongodb', '/var/lib/pgsql'].freeze

      def self.included(klass)
        klass.extend(self)
      end

      def pass?
        @devices = find_directories_devices
        return read_speed_for_single_dir if @devices.length > 1
        read_speed_for_all_dirs
      end

      def find_directories_devices
        DIRECTORY_NAMES.map { |dir| Device.new(dir).name }.uniq
      end

      def read_speed_for_single_dir
        io_cal = DiskType.check(DIRECTORY_NAMES[0])
        io_cal.read_speed >= MIN_SPEED_MBPS
      end

      def read_speed_for_all_dirs
        success = true
        DIRECTORY_NAMES.each do |dir|
          io_obj = DiskType.check(dir)
          next if io_obj.read_speed >= MIN_SPEED_MBPS
          success = false
          logger.info "\n Slow disk detected for #{dir} - #{io_obj.read_speed} #{io_obj.unit}."
          break
        end
        success
      end
    end
  end
end
