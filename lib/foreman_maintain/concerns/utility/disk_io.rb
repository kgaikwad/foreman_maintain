module ForemanMaintain
  module Concerns
    module Utility
      class DiskIO
        include SystemHelpers

        attr_accessor :dir, :unit, :read_speed

        def initialize(dir = '/var')
          @dir = dir
          stdout = hdparm
          @read_speed = extract_speed(stdout)
          @unit = extract_unit(stdout)
        end

        private

        def hdparm
          device = Device.new(dir).name
          execute("hdparm -t #{device} | awk 'NF'")
        end

        def extract_unit(stdout)
          stdout.split(' ').last
        end

        def extract_speed(stdout)
          stdout.split(' ').reverse[1].to_i
        end
      end
    end
  end
end
