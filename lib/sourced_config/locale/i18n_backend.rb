# frozen_string_literal: true

require_relative "loader"

module SourcedConfig
  module Locale
    class I18nBackend < ::I18n::Backend::Simple
      def load_translations
        return unless ::SourcedConfig.loaded?
        ::SourcedConfig[:locales][:supported].each do |locale|
          Rails.logger.info "Load I18n: for supported locale #{locale}"
          type = ::SourcedConfig[:locales][:load_from_type]
          source = ::SourcedConfig[:locales][:load_from_source]
          store_translations(locale, Loader.call!(locale.to_sym, type, source)[locale])
        end
      end
    end
  end
end
