require "json"
require "crest"
require "./utils/proxy"
require "./exceptions"

module DeepL
  class Translator
    API_URL_BASE_PRO  = "https://api.deepl.com/v2"
    API_URL_BASE_FREE = "https://api-free.deepl.com/v2"

    getter :api_url_base, :api_url_translate, :api_url_document

    def initialize
      @api_url_base = \
         auth_key_is_free_account? ? API_URL_BASE_FREE : API_URL_BASE_PRO
      @api_url_translate = "#{api_url_base}/translate"
      @api_url_document = "#{api_url_base}/document"
    end

    private def http_headers_for_text
      {
        "Authorization" => "DeepL-Auth-Key #{auth_key}",
        "User-Agent"    => user_agent,
        "Content-Type"  => "application/json",
      }
    end

    private def http_headers_for_document
      {
        "Authorization" => "DeepL-Auth-Key #{auth_key}",
        "User-Agent"    => user_agent,
      }
    end

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
      case option.action
      # when Action::Document
      #   translate_document(option)
      when Action::Text
        translate_text(
          option.input, option.target_lang, option.source_lang,
          option.formality, option.glossary_id, option.context
        )
      when Action::Document
        translate_document(
          option.input, option.target_lang
        )
      else
        raise UnknownSubCommandError.new
      end
    end

    def translate_text(
      text, target_lang, source_lang = nil, context_ = nil, split_sentences = nil,
      formality = nil, glossary_id = nil
    )
      params = Hash(String, String | Array(String)).new
      params["text"] = [text] # Multiple Sentences
      params["target_lang"] = target_lang
      params["source_lang"] = source_lang if source_lang
      params["formality"] = formality if formality
      params["glossary_id"] = glossary_id if glossary_id
      # experimental feature
      params["context"] = context_ if context_
      params["split_sentences"] = split_sentences if split_sentences

      response = Crest.post(api_url_translate, form: params, headers: http_headers_for_text, json: true)

      case response.status_code
      when 456
        QuotaExceededError.new
      when HTTP::Status::FORBIDDEN
        raise AuthorizationError.new
      when HTTP::Status::NOT_FOUND
        raise RequestError.new("Not found")
      when HTTP::Status::BAD_REQUEST
        raise RequestError.new("Bad request")
      when HTTP::Status::TOO_MANY_REQUESTS
        raise TooManyRequestsError.new
      when HTTP::Status::SERVICE_UNAVAILABLE
        raise RequestError.new("Service unavailable")
      end

      parsed_response = JSON.parse(response.body)
      parsed_response.dig("translations", 0, "text")
    end

    def translate_document(path, target_lang)
      did, dkey = upload_document(path, target_lang)

      check_status_of_document(did, dkey)

      download_document(path, target_lang, did, dkey)
    rescue ex
      raise DocumentTranslationError.new
    end

    def check_status_of_document(did, dkey)
      loop do
        sleep 10
        response = Crest.post(
          "#{api_url_document}/#{did}",
          form: {"document_key" => dkey},
          headers: http_headers_for_text,
        )
        parsed_response = JSON.parse(response.body)
        STDERR.puts parsed_response
        break if parsed_response.dig("status") == "done"
      end
    end

    def download_document(path, target_lang, did, dkey)
      response = Crest.post(
        "#{api_url_document}/#{did}/result",
        form: {"document_key" => dkey},
        headers: http_headers_for_text,
      )

      new_path = "#{path}.#{target_lang}"
      File.write(new_path, response.body)
    end

    def upload_document(path, target_lang)
      raise File::NotFoundError.new("File not found: #{path}",
        file: path) unless File.exists?(path)

      response = Crest.post(
        api_url_document,
        form: {"file" => File.open(path), "target_lang" => target_lang},
        headers: http_headers_for_document,
      )

      parsed_response = JSON.parse(response.body)
      STDERR.puts parsed_response
      document_id = parsed_response.dig("document_id")
      document_key = parsed_response.dig("document_key")

      [document_id, document_key]
    end

    def request_languages(type)
      Crest.get("#{api_url_base}/languages?type=#{type}", headers: http_headers_for_text)
    end

    def target_languages
      response = request_languages("target")
      parse_languages_response(response)
    end

    def source_languages
      response = request_languages("source")
      parse_languages_response(response)
    end

    private def parse_languages_response(response)
      (Array(Hash(String, (String | Bool)))).from_json(response.body)
    end

    def usage
      response = request_usage
      parse_usage_response(response)
    end

    private def request_usage
      Crest.get("#{api_url_base}/usage", headers: http_headers_for_text)
    end

    private def parse_usage_response(response)
      Hash(String, UInt64).from_json(response.body)
    end

    private def auth_key_is_free_account?
      auth_key.ends_with?(":fx")
    end
  end
end
