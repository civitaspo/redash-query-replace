require 'differ'

module Redash
  module Query
    module Replace
      class ReplaceQueryQueryText

        attr_reader :redash_query_client, :backup_dir

        # @param [Redash::Query::Replace::RedashQueryClient] redash_query_client
        # @param [Boolean] dry_run
        # @param [String] backup_dir
        def initialize(redash_query_client:, dry_run: true, backup_dir: Dir.mktmpdir)
          @redash_query_client = redash_query_client
          @dry_run = dry_run
          @backup_dir = backup_dir
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
          replace_query(query: query, before: query.query, from: from, to: to)
        end


        # @param [String] from
        # @param [String] to
        def replace_all(from:, to:)
          redash_query_client.list_queries do |query|
            replace_query(query: query, before: query.query, from: from, to: to)
          end
        end

        private def replace_query(query:, before:, from:, to:)
          after = before.gsub(/#{from}/, to)
          if before == after
            logger.info { "[Redash::Query::Replace::ReplaceQueryText] query id: #{query.id} does not have replacement targets."}
            return
          end

          logger.info { "[Redash::Query::Replace::ReplaceQueryText] Will replace query id: #{query.id}, from: #{from}, to: #{to}" }

          Differ.format = :color
          $stdout.puts(Differ.diff_by_word(after, before))

          backup(query_id: query.id, content: query.to_json)
          if dry_run?
            logger.info { "[Redash::Query::Replace::ReplaceQueryText] (DryRun) Finish to replace query id: #{query.id}, from: #{from}, to: #{to}" }
          else
            redash_query_client.update_query_text(id: query.id, query_text: after)
            logger.info { "[Redash::Query::Replace::ReplaceQueryText] Finish to replace query id: #{query.id}, from: #{from}, to: #{to}" }
          end
        end

        private def backup(query_id:, content:)
          fname = File.join(backup_dir, query_id.to_s)
          logger.info { "[Redash::Query::Replace::ReplaceQueryText] backup original query into: #{fname}" }
          File.write(fname, content)
        end

      end
    end
  end
end