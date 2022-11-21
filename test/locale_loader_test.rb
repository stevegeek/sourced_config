# frozen_string_literal: true

require "test_helper"
require "csv"

class LocaleLoaderTest < ActiveSupport::TestCase
  test "loads from Google Sheet TSV file" do
    gsheets = SourcedConfig::Locale::GSheetsClient.new("https://url_to_file")
    gsheets.stub :get_content, OpenStruct.new(body: +"k1\tk2\tk3\tk4\ts\na\tb\tc\td\tstr1\na\tb\te\t\tstr2\nf\t\t\t\tstr3\n") do
      h = SourcedConfig::Locale::Loader.new(
        SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_GOOGLE_SHEETS,
        "https://url_to_file",
        client: gsheets
      ).load(:en)
      assert_instance_of HashWithIndifferentAccess, h
      assert_equal "str1", h[:en][:a][:b][:c][:d]
      assert_equal "str2", h[:en][:a][:b][:e]
      assert_equal "str3", h[:en][:f]
    end
  end

  test "loads from remote file on S3 bucket" do
    loader = SourcedConfig::Locale::Loader.new(SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_S3_CONFIG, "path_to_file")
    yml = <<~YML
      en: 
        a:  
          b:
            c:  
              d: str1   
            e: str2   
        f: str3
    YML
    SourcedConfig::S3File.stub :read, yml do
      h = loader.load(:en)
      assert_instance_of HashWithIndifferentAccess, h
      assert_equal "str1", h[:en][:a][:b][:c][:d]
      assert_equal "str2", h[:en][:a][:b][:e]
      assert_equal "str3", h[:en][:f]
    end
  end

  test "loads from local file" do
    h = SourcedConfig::Locale::Loader.new(SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_LOCAL_DIRECTORY, "custom_config").load(:en)
    assert_instance_of HashWithIndifferentAccess, h
    assert_equal "str1", h[:en][:a][:b][:c][:d]
    assert_equal "str2", h[:en][:a][:b][:e]
    assert_equal "str3", h[:en][:f]
  end
end
