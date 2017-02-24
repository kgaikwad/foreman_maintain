module ForemanMaintain
  module Concerns
    module Utility
      class Device
        include SystemHelpers

        attr_accessor :name

        def initialize(dir = '/var')
          @name = find_device(dir)
        end

        private

        def find_device(dir)
          execute("df -h #{dir} | sed -n '2p' | awk '{print $1}'")
        end
      end
    end
  end
end
