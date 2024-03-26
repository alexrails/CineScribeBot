require "aws-sdk-sqs"

class QueueHandler
  class << self
    def send_to_sqs(cache_key, movies)
      sqs.send_message({
        queue_url: ENV["MESSAGES_QUEUE"],
        message_body: {
          cache_key: cache_key,
          movies: movies
        }.to_json
      })
    end

    private

    def sqs
      @@sqs ||= Aws::SQS::Client.new
    end
  end
end
