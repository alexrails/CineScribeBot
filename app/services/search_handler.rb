require "httparty"
require "digest"
require_relative "responser"
require_relative "movies_handler"
require_relative "dynamo_storage"
require_relative "queue_handler"

class SearchHandler
  extend MoviesHandler

  class << self
    def process(message, chat_id)
      title = message["text"].split(" ")[1..-1].join(" ")
      cache_key = Digest::MD5.hexdigest(title)
      cached_result = DynamoStorage.read(cache_key)

      if cached_result
        movies = cached_result
      else
        movies = movies(title)
        return Responser.new(chat_id).send_message("Movie not found!") unless movies.any?
      
        movies = handle_movie_info(movies)
        QueueHandler.send_to_sqs(cache_key, movies)
      end

      Responser.new(chat_id).send_photo(movies)
    end
  end
end
