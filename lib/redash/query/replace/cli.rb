require 'thor'
require 'dotenv'

module Redash
  module Query
    module Replace

      class Cli < Thor
        # cf. http://qiita.com/KitaitiMakoto/items/c6b9d6311c20a3cc21f9
        class << self
          def exit_on_failure?
            true
          end
        end

        class_option :log_level, aliases: ["-l"], type: :string, default: 'info', desc: 'Log level such as fatal, error, warn, info, or debug. (Default: info)'
        class_option :log, type: :string, default: 'STDOUT',desc: 'Output log to a file (Default: STDOUT)'
        class_option :env_file, type: :string, required: false, desc: 'Env vars file (Optional)'
        class_option :exec, type: :boolean, default: false, dest: 'Run actually. Dry run if this flag is no. (Default: no)'
        class_option :id, type: :numeric, required: false, desc: 'Query id. Either --id or --all option is required (Optional)'
        class_option :all, type: :boolean, default: false, desc: 'The flag that all queries became replacement targets. Either --id or --all option is required. (Default: no)'
        class_option :backup_dir, type: :string, default: nil, desc: 'backup directory (Default: create tmp dir)'

        desc "query", "Replace matched string inside query text."
        option :from, type: :string, required: true, desc: 'Replaced target regexp in query text'
        option :to, type: :string, required: true, desc: 'Replacement string'
        def query
          init
          runner = ReplaceQueryQueryText.new(redash_query_client: redash_client, dry_run: !options[:exec], backup_dir: backup_dir)
          if options[:all]
            runner.replace_all(from: options[:from], to: options[:to])
          else
            runner.replace(query_id: options[:id], from: options[:from], to: options[:to])
          end
        end

        desc "ds", "Replace data source that query has."
        option :from, type: :string, default: nil, desc: 'The replaced target data source name'
        option :to, type: :string, required: true, desc: 'Replacement data source name'
        def ds
          init
          runner = ReplaceQueryDataSource.new(redash_query_client: redash_client, dry_run: !options[:exec], backup_dir: backup_dir)
          if options[:all]
            runner.replace_all(from: options[:from], to: options[:to])
          else
            runner.replace(query_id: options[:id], data_source_name: options[:to])
          end

        end

        no_commands do
          private def init
            load_env
            setup_logger
          end

          private def setup_logger(log = options[:log], log_level = options[:log_level])
            logger = Logger.new(log)
            logger.level = log_level
            Replace.logger = logger
          end

          private def load_env(env_file = options[:env_file])
            if env_file
              Dotenv.load(env_file)
            else
              Dotenv.load
            end
          end

          private def redash_url
            ENV['REDASH_URL'] || raise(ConfigError, "[Redash::Query::Replace] env var `REDASH_URL` must be set.")
          end

          private def redash_api_key
            ENV['REDASH_API_KEY'] || raise(ConfigError, "[Redash::Query::Replace] env var `REDASH_API_KEY` must be set.")
          end

          private def redash_client
            RedashQueryClient.new(redash_url: redash_url, redash_api_key: redash_api_key)
          end

          private def backup_dir
            options[:backup_dir] || Dir.mktmpdir
          end
        end

      end
    end
  end
end