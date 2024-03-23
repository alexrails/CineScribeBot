require "httparty"

class Responser
  attr_reader :chat_id

  def initialize(chat_id)
    @chat_id = chat_id
  end

  def send_message(message)
    HTTParty.post("https://api.telegram.org/bot#{ENV["TG_TOKEN"]}/sendMessage", {
      body: {
        chat_id: chat_id,
        text: message
      }
    })
  end

  def send_photo(movies)
    movies.each do |movie|
      HTTParty.post("https://api.telegram.org/bot#{ENV["TG_TOKEN"]}/sendPhoto", {
        body: {
          chat_id: chat_id,
          photo: movie[:poster],
          caption: movie[:caption],
          parse_mode: 'Markdown'
        }
      })
    end
  rescue HTTParty::Error => e
    puts e
  ensure
    {
      statusCode: 200,
      body: {
        message: "ok"
      }
    }
  end

  def send_inline_response(results)
    body = {
      inline_query_id: chat_id,
      results: results.to_json
    }

    HTTParty.post("https://api.telegram.org/bot#{ENV["TG_TOKEN"]}/answerInlineQuery", body: body)
  end
end