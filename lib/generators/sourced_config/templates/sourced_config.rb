# frozen_string_literal: true

# Configure after autoloading of constants so schema class can be specified. But we use `to_prepare` so that configuration
# is loaded before `before_eager_load` and `after_initialize` callbacks where configuration maybe needed.
Rails.application.config.to_prepare do
  SourcedConfig.configure do |config|
    # This is the class that will be used to validate the configuration. The default is the minimum configuration
    # required, `SourcedConfig::ConfigContract` but you should create your own class that inherits from it and define
    # your own configuration schema as needed.
    config.config_schema_klass = AppConfigSchema

    # The base configuration file path. This is always required and loaded first. It can be an ERB file.
    config.base_configuration_file_path = Rails.root.join("config/config.yml.erb")

    # The type of configuration source to use. If not specified the configuration is loaded only from the default source
    # in `base_configuration_file_path`. Can be one of:
    #  `SourcedConfig::ConfigManager::SOURCE_TYPE_LOCAL_FILE`
    #  `SourcedConfig::ConfigManager::SOURCE_TYPE_S3_CONFIG_BUCKET`
    # config.config_type = SourcedConfig::ConfigManager::SOURCE_TYPE_LOCAL_FILE

    # The path to the configuration file either locally or in S3. It *cannot* be an ERB file.
    # config.configuration_file_path = "custom_config/config.yml"

    # If the remote configuration source is an S3 bucket, the bucket name of said bucket.
    # config.configuration_bucket = "my-bucket-name"

    # If the remote configuration source is an S3 bucket, the region of said bucket.
    # config.configuration_bucket_region = "us-east-1"
  end

  # `to_prepare` is called on each app reload in development mode but setup only sets up file watchers once.
  SourcedConfig.setup(Rails.application)
end
