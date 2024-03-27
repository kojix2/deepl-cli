require "json"
require "crest"
require "../ext/crest"
require "./exceptions"
require "./config"

module DeepL
  class Translator
    API_URL_BASE_PRO  = "https://api.deepl.com/v2"
    API_URL_BASE_FREE = "https://api-free.deepl.com/v2"

    record DocumentHandle, key : String, id : String

    getter :api_url_base, :api_url_translate, :api_url_document

    def initialize
      @api_url_base = \
         auth_key_is_free_account? ? API_URL_BASE_FREE : API_URL_BASE_PRO
      @api_url_translate = "#{api_url_base}/translate"
      @api_url_document = "#{api_url_base}/document"
    end

    private def http_headers_base
      {
        "Authorization" => "DeepL-Auth-Key #{auth_key}",
        "User-Agent"    => user_agent,
      }
    end

    private def http_headers_json
      http_headers_base.merge({"Content-Type" => "application/json"})
    end

    private def auth_key
      Config.auth_key
    end

    private def user_agent
      Config.user_agent
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

      response = Crest.post(api_url_translate, form: params, headers: http_headers_json, json: true)
      # TODO: Error handling

      case response.status_code
      when 456
        raise QuotaExceededError.new
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

    def translate_document(
      path, target_lang, source_lang = nil,
      formality = nil, glossary_id = nil, output_format = nil,
      output_path = nil
    )
      params = Hash(String, (String | File)).new
      params["source_lang"] = source_lang if source_lang
      params["formality"] = formality if formality
      params["target_lang"] = target_lang if target_lang
      params["glossary_id"] = glossary_id if glossary_id
      params["output_format"] = output_format if output_format

      document_handle = upload_document(path, params)

      check_status_of_document(document_handle)

      output_base_name = "#{path.stem}_#{target_lang}"
      output_extension = output_format ? ".#{output_format.downcase}" : path.extension

      output_path ||= path.parent / (output_base_name + output_extension)
      download_document(output_path, document_handle)
      # rescue ex
      #   raise DocumentTranslationError.new
    end

    def upload_document(path, params)
      file = File.open(path)
      params["file"] = file

      response = Crest.post(api_url_document, form: params, headers: http_headers_base)
      # TODO: Error handling

      parsed_response = JSON.parse(response.body)
      document_handle = DocumentHandle.new(
        key: parsed_response.dig("document_key").to_s,
        id: parsed_response.dig("document_id").to_s
      )

      STDERR.puts(
        "#{"\e[2K\r" if STDERR.tty?}" \
        "[deepl-cli] Uploaded #{path} : #{parsed_response}"
      )

      document_handle
    end

    def check_status_of_document(document_handle)
      check_status_of_document(document_handle.id, document_handle.key)
    end

    def check_status_of_document(document_id, document_key)
      url = "#{api_url_document}/#{document_id}"
      data = {"document_key" => document_key}
      loop do
        sleep 10
        response = Crest.post(url, form: data, headers: http_headers_json)
        # TODO: Error handling
        parsed_response = JSON.parse(response.body)
        STDERR.puts(
          "#{"\e[2K\r" if STDERR.tty?}" \
          "[deepl-cli] Status of document : #{parsed_response}"
        )
        status = parsed_response.dig("status")
        break if status == "done"
        raise DocumentTranslationError.new if status == "error"
      end
    end

    def download_document(output_path, document_handle)
      download_document(output_path, document_handle.id, document_handle.key)
    end

    def download_document(output_path, document_id, document_key)
      data = {"document_key" => document_key}
      url = "#{api_url_document}/#{document_id}/result"
      response = Crest.post(url, form: data, headers: http_headers_json)
      raise DocumentTranslationError.new unless response.success?

      File.write(output_path, response.body)

      STDERR.puts(
        "#{"\e[2K\r" if STDERR.tty?}" \
        "[deepl-cli] Saved #{output_path}"
      )
    end

    def request_languages(type)
      data = {"type" => type}
      url = "#{api_url_base}/languages"
      response = Crest.get(url, params: data, headers: http_headers_base)
      # TODO: Error handling
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

    def glossary_language_pairs
      url = "#{api_url_base}/glossary-language-pairs"
      response = Crest.get(url, headers: http_headers_base)
      # TODO: Error handling
      parse_glossary_language_pairs_response(response)
    end

    private def parse_glossary_language_pairs_response(response)
      Hash(String, Array(Hash(String, String)))
        .from_json(response.body)["supported_languages"]
    end

    def create_glossary(name, source_lang, target_lang, entries, entry_format = "tsv")
      data = {
        "name"           => name,
        "source_lang"    => source_lang,
        "target_lang"    => target_lang,
        "entries"        => entries,
        "entries_format" => entry_format,
      }
      url = "#{api_url_base}/glossaries"
      response = Crest.post(url, form: data, headers: http_headers_json)
      # TODO: Error handling
      parse_create_glossary_response(response)
    end

    private def parse_create_glossary_response(response)
      JSON.parse(response.body)
    end

    def delete_glossary(glossary_id : String)
      url = "#{api_url_base}/glossaries/#{glossary_id}"
      response = Crest.delete(url, headers: http_headers_base)
      # TODO: Error handling
    end

    def glossary_list
      url = "#{api_url_base}/glossaries)"
      response = Crest.get(url, headers: http_headers_base)
      # TODO: Error handling
      parse_glossary_list_response(response)
    end

    private def parse_glossary_list_response(response)
      # Hash(String, Array(Hash(String, (String | Bool | Int32))))
      #   .from_json(response.body)["glossaries"]
      #
      # Above code is better, but the following code is more robust?
      JSON.parse(response.body)["glossaries"]
    end

    def glossary_entries(glossary_id : String)
      header = http_headers_base
      header["Accept"] = "text/tab-separated-values"
      url = "#{api_url_base}/glossaries/#{glossary_id}/entries"
      response = Crest.get(url, headers: header)
      # TODO: Error handling
      response.body
    end

    private def parse_output_glossary_entries_response(response)
      JSON.parse(response.body)["entries"]
    end

    def usage
      response = request_usage
      parse_usage_response(response)
    end

    private def request_usage
      url = "#{api_url_base}/usage"
      response = Crest.get(url, headers: http_headers_base)
      # TODO: Error handling
    end

    private def parse_usage_response(response)
      Hash(String, UInt64).from_json(response.body)
    end

    private def auth_key_is_free_account?
      auth_key.ends_with?(":fx")
    end
  end
end
