# frozen_string_literal: true

require "test_helper"
require "csv"
require "minitest/mock"
require "ostruct"

class LocaleGSheetsLoaderTest < ActiveSupport::TestCase
  test "loads from remote file" do
    loader = SourcedConfig::Locale::GSheetsClient.new("https://url_to_file")
    loader.stub :get_content, OpenStruct.new(body: +"k1\tk2\tk3\tk4\ts\na\tb\tc\td\tstr\na\tb\te\t\tstr\n") do
      data = loader.load(:en)
      assert_instance_of Hash, data
      assert_equal "str", data["a"]["b"]["c"]["d"]
    end
  end
end
