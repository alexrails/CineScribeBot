require "aws-sdk-dynamodb"
require_relative "../concerns/numeric"

class DynamoStorage
  class << self
    def dynamodb
      @@dynamodb ||= Aws::DynamoDB::Client.new
    end

    def write(cache_key, sorted_movies)
      time = Time.now.to_i

      dynamodb.put_item({
        table_name: ENV["DYNAMODB_TABLE"],
        item: {
          cache_key: cache_key,
          timestamp: time,
          movies: sorted_movies.to_json,
          ttl: (time + 7.days).to_s
        }
      })
    end

    def read(cache_key)
      object = dynamodb.get_item({
        table_name: ENV["DYNAMODB_TABLE"],
        key: {
          cache_key: cache_key,
        }
      }).item

      JSON.parse(object["movies"], symbolize_names: true) if object
    end
  end
end
