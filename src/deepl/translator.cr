require "json"
require "./utils/proxy"

module Deepl
  class ApiKeyError < Exception; end

  class RequestError < Exception; end

  class Translator
    API_ENDPOINT           = "https://api-free.deepl.com/v2"
    API_TRANSLATE_ENDPOINT = "#{API_ENDPOINT}/translate"

    @http_headers : HTTP::Headers

    def initialize
      @http_headers = build_http_headers
    end

    private def build_http_headers
      HTTP::Headers{
        "Authorization" => "DeepL-Auth-Key #{api_key}",
        "Content-Type"  => "application/x-www-form-urlencoded",
      }
    end

    private def api_key
      ENV.fetch("DEEPL_API_KEY") { raise ApiKeyError.new }
    end

    def request_translation(text, target_lang, source_lang)
      params = [
        "text=#{URI.encode_www_form(text)}",
        "target_lang=#{target_lang}",
      ]
      params << "source_lang=#{source_lang}" unless source_lang == "AUTO"
      request_payload = params.join("&")
      send_post_request(request_payload)
    end

    private def send_post_request(request_data)
      HTTP::Client.post(API_TRANSLATE_ENDPOINT, body: request_data, headers: @http_headers)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    def translate(text, target_lang, source_lang)
      response = request_translation(text, target_lang, source_lang)
      parsed_response = JSON.parse(response.body)
      begin
        parsed_response.dig("translations", 0, "text")
      rescue
        raise RequestError.new("Error: #{parsed_response}")
      end
    end

    def request_languages(type)
      HTTP::Client.get("#{API_ENDPOINT}/languages?type=#{type}", headers: @http_headers)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    def target_languages
      response = request_languages("target")
      parse_languages_response(response)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    def source_languages
      response = request_languages("source")
      parse_languages_response(response)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    private def parse_languages_response(response)
      (Array(Hash(String, (String | Bool)))).from_json(response.body)
    end

    def usage
      response = request_usage
      parse_usage_response(response)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    private def request_usage
      HTTP::Client.get("#{API_ENDPOINT}/usage", headers: @http_headers)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    private def parse_usage_response(response)
      Hash(String, Int32).from_json(response.body)
    end
  end
end
