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


        option :log_level, aliases: ["-l"], type: :string, default: 'info', desc: 'Log level such as fatal, error, warn, info, or debug. (Default: info)'
        option :log, type: :string, default: 'STDOUT',desc: 'Output log to a file (Default: STDOUT)'
        option :env_file, type: :string, required: false, desc: 'Env vars file (Optional)'
        option :exec, type: :boolean, default: false, dest: 'Run actually. Dry run if this flag is no. (Default: no)'
        option :from, type: :string, required: true, desc: 'The replaced target string in query text'
        option :to, type: :string, required: true, desc: 'Replacement string'
        option :id, type: :numeric, required: false, desc: 'Query id. Either --id or --all option is required (Optional)'
        option :all, type: :boolean, default: false, desc: 'The flag that all queries became replacement targets. Either --id or --all option is required. (Default: no)'
        def query(config)
          init(config)


        end

        option :log_level, aliases: ["-l"], type: :string, default: 'info', desc: 'Log level such as fatal, error, warn, info, or debug. (Default: info)'
        option :log, type: :string, default: 'STDOUT',desc: 'Output log to a file (Default: STDOUT)'
        option :env_file, type: :string, required: false, desc: 'Env vars file (Optional)'
        option :exec, type: :boolean, default: false, dest: 'Run actually. Dry run if this flag is no. (Default: no)'
        option :from, type: :string, required: true, desc: 'The replaced target data source name'
        option :to, type: :string, required: true, desc: 'Replacement data source name'
        option :id, type: :numeric, required: false, desc: 'Query id. Either --id or --all option is required (Optional)'
        option :all, type: :boolean, default: false, desc: 'The flag that all queries became replacement targets. Either --id or --all option is required. (Default: no)'
        def ds(config)
          init(config)

        end

        private def init(config)
          load_env(config[:env_file])
          setup_logger(config[:log], config[:log_level])
        end

        private def setup_logger(log, log_level)
          logger = Logger.new(log)
          logger.level = log_level
          Replace.logger = logger
        end

        private def load_env(env_file = nil)
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

      end
    end
  end
end