# frozen_string_literal: true

require "test_helper"
require "csv"

class LocaleLoaderTest < ActiveSupport::TestCase
  test "loads from Google Sheet TSV file" do
    SourcedConfig::Locale::Loader.stub :make_http_request?, true do
      data = CSV.parse("k1\tk2\tk3\tk4\ts\na\tb\tc\td\tstr1\na\tb\te\t\tstr2\nf\t\t\t\tstr3\n", **{col_sep: "\t", quote_char: "^", headers: true})
      SourcedConfig::Locale::GSheetsLoader.stub :call, data do
        h = SourcedConfig::Locale::Loader.call!(:en, SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_GOOGLE_SHEETS, "https://url_to_file")
        assert_instance_of HashWithIndifferentAccess, h
        assert_equal "str1", h[:en][:a][:b][:c][:d]
        assert_equal "str2", h[:en][:a][:b][:e]
        assert_equal "str3", h[:en][:f]
      end
    end
  end

  test "loads from remote file on S3 bucket" do
    SourcedConfig::Locale::Loader.stub :make_http_request?, true do
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
        h = SourcedConfig::Locale::Loader.call!(:en, SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_S3_CONFIG, "path_to_file")
        assert_instance_of HashWithIndifferentAccess, h
        assert_equal "str1", h[:en][:a][:b][:c][:d]
        assert_equal "str2", h[:en][:a][:b][:e]
        assert_equal "str3", h[:en][:f]
      end
    end
  end

  test "loads from local file" do
    h = SourcedConfig::Locale::Loader.call!(:en, SourcedConfig::Locale::Loader::COPY_SOURCE_TYPE_LOCAL_DIRECTORY, "custom_config")
    assert_instance_of HashWithIndifferentAccess, h
    assert_equal "str1", h[:en][:a][:b][:c][:d]
    assert_equal "str2", h[:en][:a][:b][:e]
    assert_equal "str3", h[:en][:f]
  end
end
