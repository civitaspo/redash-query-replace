require 'redash/query/replace/version'
require 'redash/query/replace/logger'
require 'redash/query/replace/cli'

module Redash
  module Query
    module Replace

      def self.logger
        @logger ||= Logger.new(STDOUT)
      end

      def self.logger=(logger)
        @logger = logger
      end

    end
  end
end
