require "json"
require "./utils/proxy"

module DeepL
  class DeepLError < Exception
    class_property debug : Bool = false
  end

  class ApiKeyError < DeepLError
    def initialize
      super("DEEPL_AUTH_KEY is not set")
    end
  end

  class RequestError < DeepLError
    def initialize(exception : Exception)
      if DeepLError.debug
        super("#{exception.class} #{exception.message}\n#{exception.backtrace.join("\n")}")
      else
        super("#{exception.class} #{exception.message}")
      end
    end

    def initialize(message : String)
      super(message)
    end
  end

  class UnknownSubCommandError < DeepLError
    def initialize
      super("Unknown sub command")
    end
  end

  class Translator
    API_URL_BASE_PRO  = "https://api.deepl.com/v2"
    API_URL_BASE_FREE = "https://api-free.deepl.com/v2"

    getter :api_url_base, :api_url_translate

    def initialize
      @api_url_base = \
         auth_key_is_free_account? ? API_URL_BASE_FREE : API_URL_BASE_PRO
      @api_url_translate = "#{api_url_base}/translate"
    end

    private def http_headers_for_text
      HTTP::Headers{
        "Authorization" => "DeepL-Auth-Key #{auth_key}",
        "User-Agent"    => user_agent,
        "Content-Type"  => "application/x-www-form-urlencoded",
      }
    end

    # private def http_headers_for_document(content_type)
    #   HTTP::Headers{
    #     "Authorization" => "DeepL-Auth-Key #{auth_key}",
    #     "User-Agent"    => user_agent,
    #     "Content-Type"  => content_type,
    #   }
    # end

    private def auth_key
      ENV.fetch("DEEPL_AUTH_KEY") do
        # For compatibility with version 0.2.1 or earlier
        ENV.fetch("DEEPL_API_KEY") do
          raise ApiKeyError.new
        end
      end
    end

    private def user_agent
      {% if env("DEEPL_USER_AGENT") %}
        "{{ env("DEEPL_USER_AGENT") }}"
      {% else %}
        "deepl-cli/#{VERSION}"
      {% end %}
    end

    def translate(option)
      case option.sub_command
      # when SubCmd::Document
      #   translate_document(option)
      when SubCmd::Text
        translate_text(
          option.input, option.target_lang, option.source_lang,
          option.formality, option.glossary_id, option.context
        )
      else
        raise UnknownSubCommandError.new
      end
    end

    def translate_text(
      text, target_lang, source_lang = nil, context = nil, split_sentences = nil,
      formality = nil, glossary_id = nil
    )
      params = HTTP::Params.build do |form|
        form.add("text", text)
        form.add("target_lang", target_lang)
        form.add("source_lang", source_lang) if source_lang
        form.add("formality", formality) if formality
        form.add("glossary_id", glossary_id) if glossary_id
        # experimental feature
        form.add("context", context) if context
        form.add("split_sentences", split_sentences) if split_sentences
      end
      response = execute_post_request(api_url_translate, params, http_headers_for_text)
      case response.status_code
      when 456
        raise RequestError.new("Quota exceeded")
      when HTTP::Status::FORBIDDEN
        raise RequestError.new("Authorization failed")
      when HTTP::Status::NOT_FOUND
        raise RequestError.new("Not found")
      when HTTP::Status::BAD_REQUEST
        raise RequestError.new("Bad request")
      when HTTP::Status::TOO_MANY_REQUESTS
        raise RequestError.new("Too many requests")
      when HTTP::Status::SERVICE_UNAVAILABLE
        raise RequestError.new("Service unavailable")
      end
      parsed_response = JSON.parse(response.body)
      begin
        parsed_response.dig("translations", 0, "text")
      rescue ex
        raise RequestError.new(exception: ex)
      end
    end

    # def translate_document(option)
    #   io = IO::Memory.new
    #   builder = HTTP::FormData::Builder.new(io)
    #   builder.field("target_lang", option.target_lang)
    #   builder.field("source_lang", option.source_lang) unless option.source_lang == "AUTO"
    #   file = File.open(option.input)
    #   filename = File.basename(option.input)
    #   metadata = HTTP::FormData::FileMetadata.new(filename: filename)
    #   headers = HTTP::Headers{"Content-Type" => "text/plain"}
    #   builder.file("file", file, metadata, headers)
    #   builder.finish

    #   response = execute_post_request(API_URL_DOCUMENT, io, http_headers_for_document(builder.content_type))
    #   parsed_response = JSON.parse(response.body)
    #   begin
    #     parsed_response.dig("document_id")
    #   rescue ex
    #     raise RequestError.new(exception: ex)
    #   end
    # end

    private def execute_post_request(url = url, body = body, headers = headers)
      HTTP::Client.post(url, body: body, headers: headers)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    def request_languages(type)
      HTTP::Client.get("#{api_url_base}/languages?type=#{type}", headers: http_headers_for_text)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    def target_languages
      response = request_languages("target")
      parse_languages_response(response)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    def source_languages
      response = request_languages("source")
      parse_languages_response(response)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    private def parse_languages_response(response)
      (Array(Hash(String, (String | Bool)))).from_json(response.body)
    end

    def usage
      response = request_usage
      parse_usage_response(response)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    private def request_usage
      HTTP::Client.get("#{api_url_base}/usage", headers: http_headers_for_text)
    rescue ex
      raise RequestError.new(exception: ex)
    end

    private def parse_usage_response(response)
      Hash(String, UInt64).from_json(response.body)
    end

    private def auth_key_is_free_account?
      auth_key.ends_with?(":fx")
    end
  end
end
