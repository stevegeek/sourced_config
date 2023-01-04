# frozen_string_literal: true

require_relative "../s3_file"

module SourcedConfig
  module Locale
    class S3ConfigClient
      def initialize(
        bucket: ::SourcedConfig.configuration.configuration_bucket,
        region: ::SourcedConfig.configuration.configuration_bucket_region
      )
        @bucket = bucket
        @region = region
      end

      attr_reader :bucket, :region

      def load(locale)
        Rails.logger.debug "Locale read from S3 locale file"
        file = "locales/#{locale}.yml"
        str = ::SourcedConfig::S3File.read(bucket, file, region)
        yaml = YAML.safe_load(str)
        root_node = yaml[locale.to_s]
        return {} if root_node.blank?
        root_node
      end
    end
  end
end
