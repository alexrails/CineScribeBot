require "json"
require_relative "services/start_handler"
require_relative "services/search_handler"
require_relative "services/responser"

module Webhooks
  class Handler
    COMMAND_HANDLERS = {
      "/start" => StartHandler,
      "/search" => SearchHandler
    }

    def self.process(event:, context:)
      message = JSON.parse(event["body"])["message"]
      message_text = message["text"]
      command = message_text.split(" ").first
      chat_id = message.dig("chat", "id")
      handler = COMMAND_HANDLERS[command]
      
      if handler
        handler.process(message, chat_id)
      else
        Responser.new(chat_id).send_message("Wrong command or movie title is missing")
      end
    rescue => e
      puts e
    ensure

      {
        statusCode: 200,
        body: {
          message: "ok"
        }
      }
    end
  end
end
