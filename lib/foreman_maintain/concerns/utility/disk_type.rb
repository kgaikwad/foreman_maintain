module ForemanMaintain
  module Concerns
    module Utility
      class DiskType
        include SystemHelpers

        class << self
          def check(dir)
            if externally_mounted?(dir)
              FileIO
            else
              DiskIO
            end.new(dir)
          end

          def externally_mounted?(dir)
            device_type = execute("stat -f -c %T #{dir}")
            return true if %w(fuseblk nfs).include?(device_type)
            false
          end
        end
      end
    end
  end
end
