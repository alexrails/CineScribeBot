require_relative "responser"

class StartHandler
  def self.process(message, chat_id)
    name = message["from"]["first_name"]

    message =
      "Hello, #{name}! Welcome to the CineScribeBot!\n
    Use /search <movie title> to search for a movie.\n
    Example: /search The Matrix\n
    Enjoy!"

    Responser.new(chat_id).send_message(message)
  end
end
