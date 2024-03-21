require "httparty"
require 'digest'
require_relative "responser"
require_relative "s3_storage"

class SearchHandler
  TMDB_API = "https://api.themoviedb.org".freeze
  TMDB_URL = "https://image.tmdb.org/t/p/original".freeze

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

    def movies(title)
      response = HTTParty.get("#{TMDB_API}/3/search/movie", {
        query: {
          api_key: ENV["TMDB_TOKEN"],
          query: title
        },
        headers: { "Accept" => "application/json" }
      })

      response.success? ? response["results"] : nil
    rescue HTTParty::Error => e
      puts e
    end

    def handle_movie_info(movies)
      sorted_movies = sort_by_rating(movies)

      sorted_movies.each_with_object([]) do |movie, memo|
        poster_url = "#{TMDB_URL}#{movie['poster_path']}" if movie['poster_path']
        caption = "Title: #{movie['title']}\nReleased: #{movie['release_date']}\nRating: #{movie['vote_average']}\n#{movie['overview']}"
        memo << { poster: poster_url, caption: caption }
      end
    end

    def sort_by_rating(movies)
      sorted_movies = movies.sort_by { |movie| movie['vote_average'] ? -movie['vote_average'] : Float::MIN }
      sorted_movies.take(5)
    end
  end
end
