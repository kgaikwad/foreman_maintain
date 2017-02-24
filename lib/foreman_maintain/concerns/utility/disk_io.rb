module ForemanMaintain
  module Concerns
    module Utility
      class DiskIO
        include SystemHelpers

        attr_accessor :device, :dir, :unit, :speed

        def initialize(dir = '/var')
          @dir = dir
          @device, @speed, @unit  = defaults
        end

        def to_s
          "#{dir} -> #{device} : #{speed} #{unit}"
        end

        private

        def defaults
          device = get_device
          stdout = hdparm(device)
          speed = extract_speed(stdout)
          unit = extract_unit(stdout)

          return device, speed, unit
        end

        def get_device
          execute("df -h #{dir} | sed -n '2p' | awk '{print $1}'")
        end

        def hdparm(device)
          execute("hdparm -t #{device} | awk 'NF'")
        end

        def extract_unit(stdout)
          stdout.split(" ").last
        end

        def extract_speed(stdout)
          stdout.split(" ").reverse[1].to_i
        end
      end
    end
  end
end
