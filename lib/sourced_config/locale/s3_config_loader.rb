# frozen_string_literal: true

require_relative "../s3_file"

module SourcedConfig
  module Locale
    class S3ConfigLoader
      def self.call(
        locale,
        bucket: ::SourcedConfig.configuration.configuration_bucket,
        region: ::SourcedConfig.configuration.configuration_bucket_region
      )
        Rails.logger.debug "Locale read from S3 locale file"
        file = "locales/#{locale}.yml" # TODO: make this configurable
        str = ::SourcedConfig::S3File.read(bucket, file, region)
        yaml = YAML.safe_load(str)
        root_node = yaml[locale.to_s]
        return {} if root_node.blank?
        {locale.to_sym => root_node}
      end
    end
  end
end
