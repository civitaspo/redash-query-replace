require 'redash/query/replace/version'
require 'redash/query/replace/error'
require 'redash/query/replace/logger'
require 'redash/query/replace/cli'
require 'redash/query/replace/redash_query_client'
require 'redash/query/replace/replace_query_text'
require 'redash/query/replace/replace_query_data_source'


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
