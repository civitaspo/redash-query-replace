module Redash
  module Query
    module Replace
      class Error < ::StandardError; end
      class ConfigError < Error; end
      class RedashApi4XXError < Error; end
      class RedashApi5XXError < Error; end
    end
  end
end