require "json"
require_relative "services/start_handler"
require_relative "services/search_handler"
require_relative "services/responser"
require_relative "services/inline_handler"

module Webhooks
  class Handler
    COMMAND_HANDLERS = {
      "/start" => StartHandler,
      "/search" => SearchHandler
    }
    class << self
      def process(event:, context:)
        message = JSON.parse(event["body"])
        return success_response if message.dig("message", "via_bot")

        if message["inline_query"]
          InlineHandler.process(message["inline_query"])
        else
          message_text = message.dig("message", "text")
          command = message_text.split(" ").first
          chat_id = message.dig("message", "chat", "id")
          handler = COMMAND_HANDLERS[command]

          if handler
            handler.process(message["message"], chat_id)
          else
            Responser.new(chat_id).send_message("Wrong command or movie title is missing")
          end
        end
      rescue => e
        puts e
      ensure
        success_response
      end

      private

      def success_response
        {
          statusCode: 200,
          body: {
            message: "ok"
          }
        }
      end
    end
  end
end
