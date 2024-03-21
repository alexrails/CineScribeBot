require 'aws-sdk-s3'

class S3Storage
  class << self
    def s3
      @@s3 ||= Aws::S3::Client.new
    end

    def write(cache_key, movies)
      s3.put_object(
        bucket: ENV["MESSAGES_BUCKET"],
        key: cache_key,
        body: movies.to_json
      )
    end

    def read(key)
      object = s3.get_object(
        bucket: ENV["MESSAGES_BUCKET"],
        key: key
      ).body
      JSON.parse(object.read, symbolize_names: true) if object
    rescue Aws::S3::Errors::NoSuchKey
      nil
    end
  end
end
