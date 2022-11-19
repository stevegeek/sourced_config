require_relative "../../lib/app_config"

SourcedConfig.configure do |config|
  config.config_schema_klass = AppConfig
  config.config_type = SourcedConfig::ConfigManager::SOURCE_TYPE_LOCAL_FILE
  config.configuration_file_path = Rails.root.join("custom_config/config.yml")
end
