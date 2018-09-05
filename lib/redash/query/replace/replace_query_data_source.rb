module Redash
  module Query
    module Replace
      class ReplaceQueryDataSource

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
        # @param [String] data_source_name
        def replace(query_id:, data_source_name:)
          query = redash_query_client.get_query(id: query_id)
          unless ds = find_by_name(data_source_name: data_source_name)
            raise ArgumentError, "[Redash::Query::Replace::ReplaceQueryDataSource] data_source: #{data_source_name} is not found."
          end
          if query.data_source_id == ds.id
            logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] query id: #{query_id} already has data_source: #{data_source_name}" }
            return
          end

          query_ds = find_by_id(data_source_id: query.data_source_id)
          logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] Will replace query id: #{query_id} data_source: #{query_ds.name} => #{data_source_name}" }

          backup(query_id: query_id, content: query.to_json)
          if dry_run?
            logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] (DryRun) Finish to replace query id: #{query_id} data_source: #{query_ds.name} => #{data_source_name}" }
          else
            redash_query_client.update_query_data_source(id: query_id, data_source_name: data_source_name)
            logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] Finish to replace query id: #{query_id} data_source: #{query_ds.name} => #{data_source_name}" }
          end
        end


        # @param [String] from
        # @param [String] to
        def replace_all(from:, to:)
          unless from_ds = find_by_name(data_source_name: from)
            raise ArgumentError, "[Redash::Query::Replace::ReplaceQueryDataSource] data_source: #{from} is not found."
          end
          unless to_ds = find_by_name(data_source_name: to)
            raise ArgumentError, "[Redash::Query::Replace::ReplaceQueryDataSource] data_source: #{to} is not found."
          end

          redash_query_client.list_queries do |query|
            if query.data_source_id == from_ds.id
              logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] query id: #{query.id} already has data_source: #{from}" }
              next
            end

            logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] Will replace query id: #{query.id} data_source: #{from} => #{to}" }

            backup(query_id: query.id, content: query.to_json)
            if dry_run?
              logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] (DryRun) Finish to replace query id: #{query.id} data_source: #{from} => #{to}" }
            else
              redash_query_client.update_query_data_source(id: query.id, data_source_name: to)
              logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] Finish to replace query id: #{query.id} data_source: #{from} => #{to}" }
            end
          end
        end

        private def data_sources
          @data_sources ||= redash_query_client.list_data_sources
        end

        private def find_by_name(data_source_name:)
          data_sources.select { |ds| ds.name == data_source_name }.first
        end

        private def find_by_id(data_source_id:)
          data_sources.select { |ds| ds.id == data_source_id }.first
        end

        private def backup(query_id:, content:)
          fname = File.join(backup_dir, query_id.to_s)
          logger.info { "[Redash::Query::Replace::ReplaceQueryDataSource] backup original query into: #{fname}" }
          File.write(fname, content)
        end

      end
    end
  end
end