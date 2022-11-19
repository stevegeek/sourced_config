# frozen_string_literal: true

require "test_helper"
require "csv"
require "minitest/mock"
require "ostruct"

class LocaleGSheetsLoaderTest < ActiveSupport::TestCase
  test "loads from remote file" do
    SourcedConfig::Locale::GSheetsLoader.stub :get_content, OpenStruct.new(body: +"k1\tk2\tk3\tk4\ts\na\tb\tc\td\tstr\na\tb\te\t\tstr\n") do
      data = SourcedConfig::Locale::GSheetsLoader.call(:en, "https://url_to_file")
      assert_instance_of CSV::Table, data
      assert_equal 2, data.size
    end
  end
end
