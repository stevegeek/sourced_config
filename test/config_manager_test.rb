# frozen_string_literal: true

require "test_helper"

class ConfigManagerTest < ActiveSupport::TestCase
  test "#load! loads the default configuration" do
    manager = ::SourcedConfig::ConfigManager.new
    assert manager.load!(nil, nil)
    assert_kind_of Hash, manager.root(:locales)
  end

  test "#load! raises if configuration is bad" do
    manager = ::SourcedConfig::ConfigManager.new
    assert_raises SourcedConfig::InvalidConfigurationError do
      manager.load!(SourcedConfig::ConfigManager::SOURCE_TYPE_LOCAL_FILE, Rails.root.join("custom_config/bad_config.yml"))
    end
  end

  test "#reload! reloads the configuration" do
    manager = ::SourcedConfig::ConfigManager.new
    assert manager.reload!(nil, nil)
    assert_kind_of Hash, manager.root(:locales)
  end

  test "#reload! raises if configuration is bad" do
    manager = ::SourcedConfig::ConfigManager.new
    assert_raises SourcedConfig::InvalidConfigurationError do
      manager.reload!(SourcedConfig::ConfigManager::SOURCE_TYPE_LOCAL_FILE, Rails.root.join("custom_config/bad_config.yml"))
    end
  end

  test "#loaded? returns true if configuration is loaded" do
    manager = ::SourcedConfig::ConfigManager.new
    refute manager.loaded?
    manager.load!(nil, nil)
    assert manager.loaded?
  end

  test "#root raises if configuration is not loaded" do
    manager = ::SourcedConfig::ConfigManager.new
    assert_raises SourcedConfig::ConfigurationNotLoadedError do
      manager.root(:locales)
    end
  end

  test "#root raises if configuration root key not found and raise is true" do
    manager = ::SourcedConfig::ConfigManager.new
    manager.load!(nil, nil)
    assert_raises SourcedConfig::ConfigurationRootKeyNotFoundError do
      manager.root(:foo, raises: true)
    end
  end
end
