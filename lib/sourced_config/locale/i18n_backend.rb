# frozen_string_literal: true

require_relative "loader"
require_relative "null_client"

module SourcedConfig
  module Locale
    class I18nBackend < ::I18n::Backend::Simple
      def load_translations
        return unless ::SourcedConfig.loaded?
        type = ::SourcedConfig[:locales][:load_from_type]
        source = ::SourcedConfig[:locales][:load_from_source]
        null_client = Rails.env.test? ? NullClient.new : nil
        loader = Loader.new(type, source, client: null_client)
        ::SourcedConfig[:locales][:supported].each do |locale|
          Rails.logger.info "Load I18n: for supported locale #{locale}"
          store_translations(locale, loader.load(locale.to_sym)[locale])
        end
      end
    end
  end
end
