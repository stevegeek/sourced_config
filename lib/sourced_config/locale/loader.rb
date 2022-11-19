# frozen_string_literal: true

require_relative "./g_sheets_loader"
require_relative "./s3_config_loader"

module SourcedConfig
  module Locale
    class Loader
      COPY_SOURCE_TYPE_LOCAL_DIRECTORY = "local-directory"
      COPY_SOURCE_TYPE_S3_CONFIG = "s3-config"
      COPY_SOURCE_TYPE_GOOGLE_SHEETS = "google-sheets"
      COPY_SOURCE_TYPE_DEFAULT = "default"

      class << self
        def call!(locale, type, source)
          Rails.logger.debug { "[locale - #{locale}] Load copy from #{type} #{source}" }
          case type
          when COPY_SOURCE_TYPE_LOCAL_DIRECTORY
            HashWithIndifferentAccess.new load_from_local_dir(source, locale)
          when COPY_SOURCE_TYPE_S3_CONFIG
            HashWithIndifferentAccess.new load_from_config_s3(locale)
          when COPY_SOURCE_TYPE_GOOGLE_SHEETS
            locale_hash = {}
            load_from_google_sheets(locale, source).each do |row|
              parse_item(row, locale_hash)
            end
            HashWithIndifferentAccess.new(locale => HashWithIndifferentAccess.new(locale_hash))
          when COPY_SOURCE_TYPE_DEFAULT
            # Use build in copy only
            Rails.logger.warn "[locale - #{locale}] Using only default app copy"
            HashWithIndifferentAccess.new(locale => {})
          else
            raise StandardError, "When loading the Copy and Content the type was unrecognised! #{type}"
          end
        end

        private

        def load_from_config_s3(locale)
          return unless make_http_request?
          S3ConfigLoader.call(locale)
        end

        def load_from_local_dir(source, locale)
          YAML.unsafe_load_file(Rails.root.join(source, "#{locale}.yml")) || {}
        end

        def load_from_google_sheets(locale, source)
          return unless make_http_request?
          GSheetsLoader.call(locale, source, tsv_options)
        rescue => e
          Rails.logger.error "[locale - en] Could not fetch TSV doc directly from Google Spreadsheets: #{e.message}"
        end

        def tsv_options
          {
            col_sep: "\t",
            quote_char: "^",
            skip_lines: /^\s*#.*$/,
            skip_blanks: true,
            headers: true
          }
        end

        def make_http_request?
          !Rails.env.test?
        end

        def parse_item(item, locale_hash)
          *keys, string = item.to_a.map { |x| x[1] }
          keys.compact!
          leaf_item = keys[..-2].reduce(locale_hash) do |h, k|
            next h unless k.present?
            h[k] ||= {}
          end
          leaf_item[keys.last] = string
        end
      end
    end
  end
end
