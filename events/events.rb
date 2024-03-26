require 'aws-sdk-dynamodb'
require 'json'
require_relative "concerns/numeric"

def lambda_handler(event:, context:)
  event['Records'].each do |record|
    message = JSON.parse(record['body'], symbolize_names: true)
    cache_key = message[:cache_key]
    movies = message[:movies]
    time = Time.now.to_i
    ttl = time + 7.days

    begin
      dynamodb.put_item({
        table_name: ENV["DYNAMODB_TABLE"],
        item: {
          cache_key: cache_key,
          timestamp: time,
          movies: movies.to_json,
          ttl: ttl
        }
      })
    rescue Aws::DynamoDB::Errors::ServiceError => e
      puts "Unable to save data to DynamoDB: #{e}"
    end
  end
end

def dynamodb
  @dynamodb ||= Aws::DynamoDB::Client.new
end
