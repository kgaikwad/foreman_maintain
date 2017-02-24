module ForemanMaintain
  module Concerns
    module Utility
      class DiskType
        class << self
          def check(dir)
            if nfs?(dir)
              FileIO
            else
              DiskIO
            end.new(dir)
          end

          def nfs?(dir)
            false
          end
        end
      end
    end
  end
end
