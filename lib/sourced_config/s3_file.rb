# frozen_string_literal: true

module SourcedConfig
  class S3File
    def self.read(bucket, path, region, retry_limit: 10)
      s3 = Aws::S3::Client.new(retry_limit: retry_limit, region: region)
      resp = s3.get_object(bucket: bucket, key: path)
      resp.body
    end
  end
end
