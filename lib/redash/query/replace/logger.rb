require 'logger'

module Redash
  module Query
    module Replace

      class Logger < ::Logger
        def initialize(logdev, shift_age = 0, shift_size = 1048576)
          logdev = STDOUT if logdev == 'STDOUT'
          super(logdev, shift_age, shift_size)
        end

        def level=(level)
          level = eval("::Logger::#{level.upcase}") if level.is_a?(String)
          super(level)
        end

        def write(msg)
          @logdev.write msg
        end
      end

    end
  end
end