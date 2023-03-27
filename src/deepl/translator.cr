require "http/client"
require "json"

module Deepl
    class ApiKeyError < Exception; end
    class RequestError < Exception; end
  
    class Translator
      API_ENDPOINT = "https://api-free.deepl.com/v2/translate"
  
      @http_headers : HTTP::Headers
  
      def initialize
        @http_headers = build_http_headers
      end
  
      def build_http_headers
        HTTP::Headers{
          "Authorization" => "DeepL-Auth-Key #{get_api_key}",
          "Content-Type"  => "application/x-www-form-urlencoded",
        }
      end
  
      def get_api_key
        if ENV.has_key?("DEEPL_API_KEY")
          ENV["DEEPL_API_KEY"]
        else
          raise ApiKeyError.new
        end
      end
  
      def request_translation(text : String, target_lang : String)
        request_payload = "text=#{URI.encode_www_form(text)}&target_lang=#{URI.encode_www_form(target_lang)}"
        send_post_request(request_payload)
      end
  
      def send_post_request(request_data : String)
        HTTP::Client.post(API_ENDPOINT, body: request_data, headers: @http_headers)
      rescue error
        raise RequestError.new("Error: #{error} #{error.message}")
      end
  
      def translate(text, target_lang)
        response = request_translation(text, target_lang)
        parsed_response = JSON.parse(response.body)
        parsed_response.dig("translations", 0, "text")
      end
    end
  end