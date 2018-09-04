require 'rest-client'
require 'hashie/mash'
require 'json'

module Redash
  module Query
    module Replace

      class RedashQueryClient

        attr_reader :redash_url, :redash_api_key

        def initialize(redash_url:, redash_api_key:)
          @redash_url = redash_url
          @redash_api_key = redash_api_key
        end

        def list_queries(&query_proc)
          url = build_url('/api/queries')
          max_results = 250
          list_queries_proc = proc do |page|
            params = {
              api_key: redash_api_key,
              page: page,
              page_size: max_results
            }
            logger.debug { "[Redash::Query::Replace::RedashQueryClient] list_queries params: #{mask_values(params)}" }
            res = rescue_request_failed do
              RestClient.get(url, params: params)
            end
            Hashie::Mash.new(JSON.parse(res.body))
          end
          num_loop = 0
          until (r = list_queries_proc.call(num_loop += 1)).results.size < max_results do
            r.results.each do |result|
              query_proc.call(result)
            end
          end
        end

        def get_query(id:)
          url = build_url("/api/queries/#{id}")
          params = {
            api_key: redash_api_key,
          }
          logger.debug { "[Redash::Query::Replace::RedashQueryClient] get_query params: #{mask_values(params)}" }
          res = rescue_request_failed do
            RestClient.get(url, params: params)
          end
          Hashie::Mash.new(JSON.parse(res.body))
        end

        def list_data_sources
          url = build_url('/api/data_sources')
          params = {
            api_key: redash_api_key,
          }
          logger.debug { "[Redash::Query::Replace::RedashQueryClient] list_data_sources params: #{mask_values(params)}" }
          res = rescue_request_failed do
            RestClient.get(url, params: params)
          end
          JSON.parse(res.body).map do |ds|
            Hashie::Mash.new(ds)
          end
        end

        def update_query_text(id:, query_text:)
          raise ArgumentError, "[Redash::Query::Replace::RedashQueryClient] update_query_text: id must be Numeric" unless id.is_a?(Numeric)
          raise ArgumentError, "[Redash::Query::Replace::RedashQueryClient] update_query_text: query_text must be String" unless query_text.is_a?(String)
          url = build_url("/api/queries/#{id}")
          params = {
            api_key: redash_api_key
          }
          payload = {
            query: query_text,
          }
          logger.debug { "[Redash::Query::Replace::RedashQueryClient] update_query_text params: #{mask_values(params)}, query: #{query_text}" }
          res = rescue_request_failed do
            RestClient.post(url, payload.to_json, params: params, "Content-Type" => "application/json")
          end
          Hashie::Mash.new(JSON.parse(res.body))
        end

        def update_query_data_source(id:, data_source_name:)
          raise ArgumentError, "[Redash::Query::Replace::RedashQueryClient] update_query_data_source: id must be Numeric" unless id.is_a?(Numeric)
          raise ArgumentError, "[Redash::Query::Replace::RedashQueryClient] update_query_data_source: data_source_name must be String" unless data_source_name.is_a?(String)

          unless data_source_id = list_data_sources.select {|ds| ds.name == data_source_name}.first&.id
            raise(ArgumentError, "[Redash::Query::Replace::RedashQueryClient] update_query_data_source: data_source_name: #{data_source_name} is not found.")
          end

          url = build_url("/api/queries/#{id}")
          params = {
            api_key: redash_api_key
          }
          payload = {
            data_source_id: data_source_id,
          }
          logger.debug { "[Redash::Query::Replace::RedashQueryClient] update_query_data_source params: #{mask_values(params)}, data_source_id: #{data_source_id}" }
          res = rescue_request_failed do
            RestClient.post(url, payload.to_json, params: params, "Content-Type" => "application/json")
          end
          Hashie::Mash.new(JSON.parse(res.body))
        end

        private def logger
          Replace.logger
        end

        private def build_url(path)
          File.join(redash_url, path)
        end

        private def rescue_request_failed(&request_proc)
          request_proc.call
        rescue RestClient::RequestFailed => e
          case e.response.code / 100
          when 4 then raise RedashApi4XXError, "response: #{e.response}, message: #{e.message}"
          when 5 then raise RedashApi5XXError, "response: #{e.response}, message: #{e.message}"
          else raise e
          end
        end

        private def mask_values(hash)
          mask_keys = %i(api_key)
          hash.dup.tap do |dup_hash|
            mask_keys.each do |k|
              dup_hash[k] = "xxxxxxxx (masked)"
            end
          end
        end

      end

    end
  end
end