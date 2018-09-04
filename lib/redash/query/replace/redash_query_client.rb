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
            res = RestClient.get(url, params: params)
            raise_if_error_code(res)
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
          res = RestClient.get(url, params: params)
          raise_if_error_code(res)
          Hashie::Mash.new(JSON.parse(res.body))
        end

        private def logger
          Replace.logger
        end

        private def build_url(path)
          File.join(redash_url, path)
        end

        private def raise_if_error_code(res)
          case res.code / 100
          when 4
            raise RedashApi4XXError, res.body
          when 5
            raise RedashApi5XXError, res.body
          else
            logger.debug { "code: #{res.code}, headers: #{mask_values(res.headers)}" }
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