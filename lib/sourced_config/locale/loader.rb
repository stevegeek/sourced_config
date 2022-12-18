# frozen_string_literal: true

require_relative "./g_sheets_client"
require_relative "./s3_config_client"

module SourcedConfig
  module Locale
    class Loader
      COPY_SOURCE_TYPE_LOCAL_DIRECTORY = "local-directory"
      COPY_SOURCE_TYPE_S3_CONFIG = "s3-config"
      COPY_SOURCE_TYPE_GOOGLE_SHEETS = "google-sheets"
      COPY_SOURCE_TYPE_DEFAULT = "default"

      def initialize(type, source, client: nil)
        @type = type
        @source = source
        @client = client
      end

      attr_reader :locale, :type, :source

      def load(locale)
        Rails.logger.debug { "[locale - #{locale}] Load copy from #{type} #{source}" }
        case type
        when COPY_SOURCE_TYPE_LOCAL_DIRECTORY
          HashWithIndifferentAccess.new load_from_local_dir(locale)
        when COPY_SOURCE_TYPE_S3_CONFIG, COPY_SOURCE_TYPE_GOOGLE_SHEETS
          HashWithIndifferentAccess.new(locale => HashWithIndifferentAccess.new(client.load(locale)))
        when COPY_SOURCE_TYPE_DEFAULT
          Rails.logger.warn "[locale - #{locale}] Using only default app copy"
          HashWithIndifferentAccess.new(locale => {})
        else
          raise StandardError, "When loading the locales the type was unrecognised! #{type}"
        end
      end

      private

      def client
        return @client if @client
        @client = case type
        when COPY_SOURCE_TYPE_S3_CONFIG
          S3ConfigClient.new
        when COPY_SOURCE_TYPE_GOOGLE_SHEETS
          GSheetsClient.new(source)
        end
      end

      def load_from_local_dir(locale)
        YAML.safe_load_file(Rails.root.join(source, "#{locale}.yml")) || {}
      end
    end
  end
end
