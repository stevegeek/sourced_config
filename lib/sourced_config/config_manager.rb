# frozen_string_literal: true

module SourcedConfig
  class ConfigManager
    SOURCE_TYPE_LOCAL_FILE = "local_file"
    SOURCE_TYPE_S3_CONFIG_BUCKET = "s3_config_bucket"

    def root(key, raises: false)
      raise ConfigurationNotLoadedError, "You cannot access config nodes until you have loaded configuration!" unless loaded?
      raise ConfigurationRootKeyNotFoundError, "Config key #{key} not found" if raises && !configuration.key?(key)
      configuration[key]
    end

    def load!(external_type, external_source_path)
      Rails.logger.info "Load configuration data from #{external_type} - #{external_source_path}" if external_type
      if loaded?
        Rails.logger.warn "An attempt to load configuration happened when it is already loaded"
        return false
      end
      primary_config = load_yaml_and_parse_erb(SourcedConfig.configuration.base_configuration_file_path).deep_symbolize_keys
      external = external_type.present? && load_external_config(external_type, external_source_path).deep_symbolize_keys

      schema = SourcedConfig.configuration.config_schema_klass.new
      config_contract = schema.call(external ? primary_config.deep_merge(external) : primary_config)
      if config_contract.failure?
        messages = config_contract.errors(full: true).to_h
        Rails.logger.error "Error in configuration file! #{messages}"
        raise InvalidConfigurationError, "Failed to load configuration data! #{messages}"
      end
      @configuration = config_contract

      loaded?
    end

    # Reload configuration files, only in development, this is hooked up to a file watcher on the config file
    # and external directory if specified.
    def reload!(external_type, external_source_path, force: false)
      return false if Rails.env.production? && !force
      Rails.logger.warn "Something changed: Reloading application configuration!"
      @configuration = nil
      load!(external_type, external_source_path)
    end

    def loaded?
      configuration.present?
    end

    private

    attr_reader :configuration

    def load_external_config(external_type, external_source_path)
      Rails.logger.info "Load external configuration data #{external_type}: #{external_source_path}"
      case external_type
      when SOURCE_TYPE_LOCAL_FILE
        load_yaml(external_source_path)
      when SOURCE_TYPE_S3_CONFIG_BUCKET
        load_s3_config_bucket_file(external_source_path)
      else
        Rails.logger.error "Cannot load external configuration data for unknown #{external_type}"
        raise ArgumentError, "Invalid external file type"
      end
    end

    def load_yaml_and_parse_erb(file)
      parsed = ERB.new(File.read(file)).result(binding)
      parse_yaml(parsed)
    end

    def parse_yaml(str)
      YAML.safe_load(str, permitted_classes: [Symbol])
    end

    def load_s3_config_bucket_file(path)
      file = path || s3_file_path
      Rails.logger.info "Loading from S3 #{s3_bucket} - #{s3_region} - #{file}"
      s = SourcedConfig::S3File.read(s3_bucket, file, s3_region)
      parse_yaml(s)
    end

    def s3_file_path
      SourcedConfig.configuration.configuration_file_path
    end

    def s3_bucket
      SourcedConfig.configuration.configuration_bucket
    end

    def s3_region
      SourcedConfig.configuration.configuration_bucket_region
    end

    def load_yaml(file)
      YAML.safe_load_file(file, permitted_classes: [Symbol])
    end
  end
end
