require_relative "movies_handler"
require_relative "responser"
require_relative "../concerns/cache_strategy"

class InlineHandler
  extend MoviesHandler
  extend CacheStrategy
  
  class << self
    def process(inline_query)
      query_id = inline_query['id']
      title = inline_query['query']
      cache_key = Digest::MD5.hexdigest(title)
      cached_result = read_from_cache(cache_key)

      if cached_result
        movies = cached_result
      else
        movies = movies(title)
        movies = handle_movie_info(movies)
        storage_klass.write(cache_key, movies)
      end

      results = movies.map.with_index do |movie, index|
        {
          type: "article",
          id: index.to_s,
          title: movie[:caption],
          input_message_content: {
            message_text: movie[:caption],
            parse_mode: "Markdown"
          },
          thumbnail_url: movie[:poster]
        }
      end

      Responser.new(query_id).send_inline_response(results)
    end
  end
end
