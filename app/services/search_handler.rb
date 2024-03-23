require "httparty"
require 'digest'
require_relative "responser"
require_relative "s3_storage"
require_relative "movies_handler"

class SearchHandler
  extend MoviesHandler

  class << self
    def process(message, chat_id)
      title = message['text'].split(' ')[1..-1].join(' ')
      cache_key = Digest::MD5.hexdigest(title)
      cached_result = read_from_cache(cache_key)

      if cached_result
        movies = cached_result
      else
        movies = movies(title)
        return Responser.new(chat_id).send_message("Movie not found!") unless movies.any?
      
        movies = handle_movie_info(movies)
        S3Storage.write(cache_key, movies)
      end

      Responser.new(chat_id).send_photo(movies)
    end

    private

    def read_from_cache(cache_key)
      S3Storage.read(cache_key)
    end
  end
end
