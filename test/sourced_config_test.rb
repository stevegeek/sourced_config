require "test_helper"

class SourcedConfigTest < ActiveSupport::TestCase
  test "it has a version number" do
    assert SourcedConfig::VERSION
  end

  test ".load!(force: true)" do
    SourcedConfig.load!(force: true)
    assert_equal "test", SourcedConfig[:environment]
    assert_equal "black", SourcedConfig[:footer_color]
  end

  test ".startup_time" do
    assert_instance_of ActiveSupport::TimeWithZone, SourcedConfig.startup_time
  end

  test ".[]" do
    assert_instance_of Hash, SourcedConfig[:locales]
    assert_equal "str1", I18n.t("a.b.c.d")
    assert_equal "My Client Whitelabel Name", SourcedConfig[:app_name]
  end

  test ".dig" do
    assert_equal "local-directory", SourcedConfig.dig(:locales, :load_from_type)
    assert_nil SourcedConfig.dig(:locales, :bar, :foo)
  end

  test ".loaded?" do
    assert SourcedConfig.loaded?
  end
end
