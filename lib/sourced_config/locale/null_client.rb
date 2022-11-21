# frozen_string_literal: true

module SourcedConfig
  module Locale
    class NullClient
      def load(_locale)
        {}
      end
    end
  end
end
