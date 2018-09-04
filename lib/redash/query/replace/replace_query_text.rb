require 'differ'

module Redash
  module Query
    module Replace
      class ReplaceQueryText

        attr_reader :redash_query_client

        # @param [Redash::Query::Replace::RedashQueryClient] redash_query_client
        # @param [Boolean] dryrun
        def initialize(redash_query_client:, dry_run: true)
          @redash_query_client = redash_query_client
          @dry_run = dry_run
        end

        private def dry_run?
          @dry_run
        end

        private def logger
          Replace.logger
        end

        # @param [Numeric] query_id
        # @param [String] from
        # @param [String] to
        def replace(query_id:, from:, to:)
          query = redash_query_client.get_query(id: query_id)
          replace_query(query_id: query.id, before: query.query, from: from, to: to)
        end


        # @param [String] from
        # @param [String] to
        def replace_all(from:, to:)
          redash_query_client.list_queries do |query|
            replace_query(query_id: query.id, before: query.query, from: from, to: to)
          end
        end

        private def replace_query(query_id:, before:, from:, to:)
          logger.info { "[Redash::Query::Replace::ReplaceQueryText] Replace query id: #{query_id}, from: #{from}, to: #{to}" }
          after = before.gsub(/#{from}/, to)
          if before == after
            logger.info { "[Redash::Query::Replace::ReplaceQueryText] query id: #{query_id} does not have replacement targets."}
            return
          end
          Differ.format = :color
          $stdout.puts(Differ.diff_by_word(after, before))
          unless dry_run?
            redash_query_client.update_query_text(id: query_id, query_text: after)
          end
        end

      end
    end
  end
end