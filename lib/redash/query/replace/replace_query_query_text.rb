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
          backup(query_id: query_id, content: query.to_json)
          replace_query(query_id: query.id, before: query.query, from: from, to: to)
        end


        # @param [String] from
        # @param [String] to
        def replace_all(from:, to:)
          redash_query_client.list_queries do |query|
            backup(query_id: query.id, content: query.to_json)
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

        private def backup(query_id:, content:)
          fname = File.join(backup_dir, query_id.to_s)
          logger.info { "[Redash::Query::Replace::ReplaceQueryText] backup original query into: #{fname}" }
          File.write(fname, content)
        end

      end
    end
  end
end