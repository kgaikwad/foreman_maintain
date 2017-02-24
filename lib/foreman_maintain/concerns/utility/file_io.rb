module ForemanMaintain
  module Concerns
    module Utility
      class FileIO
        include SystemHelpers

        attr_accessor :dir, :unit, :read_speed

        def initialize(dir)
          @dir = dir
          @unit = 'MB/sec'
          bw_in_kb = fio
          @read_speed = convert_kb_to_mb(bw_in_kb)
        end

        private

        # In fio command, --direct option bypass the cache page
        def fio
          cmd  = "fio --name=job1 --rw=read --size=1g --output-format=json --directory=#{dir} --direct=1"
          stdout = execute(cmd)
          output = JSON.parse(stdout)
          output['jobs'].first['read']['bw'].to_i
        end

        def convert_kb_to_mb(val)
          val / 1024
        end
      end
    end
  end
end
