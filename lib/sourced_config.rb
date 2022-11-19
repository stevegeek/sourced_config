# frozen_string_literal: true

require_relative "sourced_config/version"
require_relative "sourced_config/railtie"
require_relative "sourced_config/config_manager"
require_relative "sourced_config/config_contract"
require_relative "sourced_config/locale/i18n_backend"

module SourcedConfig
  class ConfigurationNotLoadedError < StandardError; end

  class InvalidConfigurationError < StandardError; end

  class ConfigurationRootKeyNotFoundError < StandardError; end

  class << self
    attr_reader :configuration

    def configure
      @configuration ||= Configuration.new
      yield(configuration) if block_given?
      configuration
    end
  end

  class Configuration
    attr_accessor :config_schema_klass,
      :config_type,
      :base_configuration_file_path, # Can also be ERB
      :configuration_bucket,
      :configuration_bucket_region,
      :configuration_file_path # Can not be ERB

    def initialize
      @config_schema_klass = ConfigContract
      @base_configuration_file_path = Rails.root.join("config/config.yml.erb")
    end
  end

  # The configuration class API
  # Uses the ConfigManager to actually hold and prepare configuration data
  class << self
    # https://github.com/rails/rails/blob/master/activesupport/lib/active_support/i18n_railtie.rb
    @inited = false

    def config_type_file?
      configuration.config_type == ConfigManager::SOURCE_TYPE_LOCAL_FILE
    end

    def setup(app)
      return if @inited

      I18n.backend = I18n::Backend::Chain.new(Locale::I18nBackend.new, I18n.backend)

      files = [configuration.base_configuration_file_path]

      files << Rails.root.join(configuration.configuration_file_path) if config_type_file?

      reloader = app.config.file_watcher.new(files) do
        Rails.logger.warn "*** Application configuration changed in #{Rails.env} " \
            "(zeitwerk: #{Rails.autoloaders.zeitwerk_enabled?})"
        SourcedConfig.load!(configuration.config_type, configuration.configuration_file_path)
      end

      app.reloaders << reloader
      app.reloader.to_run do
        # We are *not* using execute_if_updated cause if anything causes Classes to be reloaded it will kill the config
        # persisted in the class variable in the Config singleton. So we want to always execute a reload (eg when
        # I18n content changes)
        reloader.execute { require_unload_lock! }
      end

      # Load now
      reloader.execute

      @started_up ||= Time.zone.now
      @inited = true
    end

    def load!(type = SourcedConfig.configuration.config_type, source_path = SourcedConfig.configuration.configuration_file_path, force: false)
      loaded? ? manager.reload!(type, source_path, force: force) : manager.load!(type, source_path)
    end

    def startup_time
      @started_up
    end

    # Get a key from the configuration
    def [](key)
      manager.root(key)
    end

    # Dig lets you reach in and extract deeply nested keys from an array of keys. Note will NOT raise if the key
    # doesnt exist, like Hash#dig etc
    def dig(root, *keys)
      manager.root(root).dig(*keys)
    end

    def loaded?
      manager&.loaded?
    end

    private

    def manager
      @manager ||= ConfigManager.new
    end
  end
end
