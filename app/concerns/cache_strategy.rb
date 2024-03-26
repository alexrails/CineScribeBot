require_relative "../services/s3_storage"
require_relative "../services/dynamo_storage"

module CacheStrategy
  private

  def read_from_cache(cache_key)
    storage_klass.read(cache_key)
  end

  def storage_klass
    ENV["CACHE_STRATEGY"] == "dynamodb" ? DynamoStorage : S3Storage
  end
end
