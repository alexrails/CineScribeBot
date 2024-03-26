require "aws-sdk-dynamodb"

class DynamoStorage
  class << self
    def read(cache_key)
      object = dynamodb.get_item({
        table_name: ENV["DYNAMODB_TABLE"],
        key: {
          cache_key: cache_key,
        }
      }).item

      JSON.parse(object["movies"], symbolize_names: true) if object
    end

    private

    def dynamodb
      @@dynamodb ||= Aws::DynamoDB::Client.new
    end
  end
end
