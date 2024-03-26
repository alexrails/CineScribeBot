require_relative "movies_handler"
require_relative "responser"
require_relative "dynamo_storage"
require_relative "queue_handler"

class InlineHandler
  extend MoviesHandler
  
  class << self
    def process(inline_query)
      query_id = inline_query["id"]
      title = inline_query["query"]
      cache_key = Digest::MD5.hexdigest(title)
      cached_result = DynamoStorage.read(cache_key)

      if cached_result
        movies = cached_result
      else
        movies = movies(title)
        movies = handle_movie_info(movies)
        QueueHandler.send_to_sqs(cache_key, movies)
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
