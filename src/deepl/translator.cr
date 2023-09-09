require "json"
require "./utils/proxy"

module Deepl
  class ApiKeyError < Exception; end

  class RequestError < Exception; end

  class Translator
    API_BASE_URL = {% if env("DEEPL_API_PRO") %}
                     "https://api.deepl.com/v2"
                   {% else %}
                     "https://api-free.deepl.com/v2"
                   {% end %}
    API_TRANSLATE_URL = "#{API_BASE_URL}/translate"

    @http_headers : HTTP::Headers

    def initialize
      @http_headers = build_http_headers
    end

    private def build_http_headers
      HTTP::Headers{
        "Authorization" => "DeepL-Auth-Key #{api_key}",
        "User-Agent"    => user_agent,
        "Content-Type"  => "application/x-www-form-urlencoded",
      }
    end

    private def api_key
      ENV.fetch("DEEPL_API_KEY") { raise ApiKeyError.new }
    end

    private def user_agent
      {% if env("DEEPL_USER_AGENT") %}
        "{{ env("DEEPL_USER_AGENT") }}"
      {% else %}
        "deepl-cli/#{VERSION}"
      {% end %}
    end

    def get_translation(text, target_lang, source_lang)
      params = [
        "text=#{URI.encode_www_form(text)}",
        "target_lang=#{target_lang}",
      ]
      params << "source_lang=#{source_lang}" unless source_lang == "AUTO"
      request_payload = params.join("&")
      execute_post_request(request_payload)
    end

    private def execute_post_request(request_payload)
      HTTP::Client.post(API_TRANSLATE_URL, body: request_payload, headers: @http_headers)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    def translate(text, target_lang, source_lang)
      response = get_translation(text, target_lang, source_lang)
      parsed_response = JSON.parse(response.body)
      begin
        parsed_response.dig("translations", 0, "text")
      rescue
        raise RequestError.new("Error: #{parsed_response}")
      end
    end

    def translate(option)
      translate(option.input, option.target_lang, option.source_lang)
    end

    def request_languages(type)
      HTTP::Client.get("#{API_BASE_URL}/languages?type=#{type}", headers: @http_headers)
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
      HTTP::Client.get("#{API_BASE_URL}/usage", headers: @http_headers)
    rescue ex
      raise RequestError.new("Error: #{ex.message}")
    end

    private def parse_usage_response(response)
      Hash(String, Int32).from_json(response.body)
    end
  end
end
