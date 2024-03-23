module MoviesHandler
  TMDB_API = "https://api.themoviedb.org".freeze
  TMDB_URL = "https://image.tmdb.org/t/p/original".freeze

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
