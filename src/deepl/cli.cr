require "../ext/crest"
require "deepl"
require "json"
require "./prompt"
require "./term_spinner"
require "./parser"
require "./utils"

module DeepL
  class CLI
    class_property? debug : Bool = false

    ANSI_ESCAPE_REGEX = Regex.new(
      "(?:\x1B[@-Z\\-_]|[\\x80-\\x9A\\x9C-\\x9F]|(?:\x1B\\[|\\x9B)[0-?]*[ -/]*[@-~])"
    )

    getter parser : Parser
    getter option : Options

    def initialize
      @parser = DeepL::Parser.new
      @option = parser.parse(ARGV)
    end

    def run
      case option.action
      when Action::TranslateText
        translate_text
      when Action::RephraseText
        rephrase_text
      when Action::CorrectText
        correct_text
      when Action::TranslateDocument
        translate_document
      when Action::TranslateDocumentUpload
        upload_document_to_translate
      when Action::TranslateDocumentStatus
        check_document_translation_status
      when Action::TranslateDocumentDownload
        download_translated_document
      when Action::CreateGlossary
        create_glossary
      when Action::DeleteGlossaryByName
        delete_glossary_by_name
      when Action::DeleteGlossaryById
        delete_glossary_by_id
      when Action::EditGlossaryByName
        edit_glossary_by_name
      when Action::EditGlossaryById
        edit_glossary_by_id
      when Action::ListGlossaries
        print_glossary_list
      when Action::ListGlossariesLong
        print_glossary_list_long
      when Action::OutputGlossaryEntriesByName
        output_glossary_entries_by_name
      when Action::OutputGlossaryEntriesById
        output_glossary_entries_by_id
      when Action::ListFromLanguages
        print_source_languages
      when Action::ListTargetLanguages
        print_target_languages
      when Action::RetrieveUsage
        print_usage
      when Action::Version
        print_version
      when Action::Help
        if message = option.help_error_message
          abort_with_help(message)
        else
          print_help
        end
      else
        raise ArgumentError.new("Invalid action: #{option.action}")
      end
    rescue ex
      error_message = "\n[deepl-cli] ERROR: #{ex.class} #{ex.message}"
      if ex.is_a?(DeepL::DeepLError)
        if trace_id = ex.trace_id
          error_message += "\n[deepl-cli] Trace ID: #{trace_id}"
        end
      end
      {% if flag?(:debug) %}
        error_message += "\n#{ex.backtrace.join("\n")}" if CLI.debug?
      {% end %}
      STDERR.puts error_message
      exit(1)
    end

    private def with_spinner(&block : -> T) : T forall T
      spinner = Term::Spinner.new(clear: true)
      spinner.run do
        block.call
      end
    end

    private def remove_ansi_escape_codes(text : String) : String
      text.gsub(ANSI_ESCAPE_REGEX, "")
    end

    private def prepared_input_text : String
      option.input_text = ARGF.gets_to_end if option.input_text.empty?
      option.input_text = remove_ansi_escape_codes(option.input_text) if option.no_ansi?
      option.input_text
    end

    def translate_text
      validate_translation_options
      input_text = prepared_input_text
      translator = DeepL::Translator.new

      result = with_spinner do
        translator.translate_text(
          text: input_text,
          target_lang: option.target_lang,
          source_lang: option.source_lang,
          formality: option.formality,
          split_sentences: option.split_sentences,
          preserve_formatting: option.preserve_formatting?,
          tag_handling: option.tag_handling,
          outline_detection: option.outline_detection?,
          non_splitting_tags: option.non_splitting_tags,
          splitting_tags: option.splitting_tags,
          ignore_tags: option.ignore_tags,
          glossary_id: option.glossary_id,
          glossary_ids: option.glossary_ids,
          glossary_name: option.glossary_name,
          context: option.context,
          show_billed_characters: option.show_billed_characters?,
          model_type: option.model_type,
        )
      end

      output = option.output_file ? IO::Memory.new : STDOUT

      result.each do |result_item|
        if option.detect_source_language?
          STDERR.puts "[deepl-cli] Detected source language: #{result_item.detected_source_language}"
        end
        if option.show_billed_characters?
          STDERR.puts "[deepl-cli] Billed characters: #{result_item.billed_characters}"
        end
        output.puts result_item.text
      end
      if output_file = option.output_file
        File.open(output_file, "w") do |output_file_handle|
          output.to_s(output_file_handle)
        end
        STDERR.puts "[deepl-cli] Translated text is written to #{output_file}"
      end
    end

    def rephrase_text
      input_text = prepared_input_text
      translator = DeepL::Translator.new

      result = with_spinner do
        translator.rephrase_text(
          text: input_text,
          target_lang: normalize_write_language(option.source_lang), # source_lang is correct here.
          writing_style: option.writing_style,
          tone: option.tone
        )
      end

      output = option.output_file ? IO::Memory.new : STDOUT

      result.each do |result_item|
        if option.detect_source_language?
          STDERR.puts "[deepl-cli] Detected source language: #{result_item.detected_source_language}"
        end
        output.puts result_item.text
      end

      if output_file = option.output_file
        File.open(output_file, "w") do |output_file_handle|
          output.to_s(output_file_handle)
        end
        STDERR.puts "[deepl-cli] Rephrased text is written to #{output_file}"
      end
    end

    def correct_text
      input_text = prepared_input_text
      translator = DeepL::Translator.new

      result = with_spinner do
        translator.correct_text(
          text: input_text,
          target_lang: normalize_write_language(option.source_lang),
        )
      end

      output = option.output_file ? IO::Memory.new : STDOUT

      result.each do |result_item|
        if option.detect_source_language?
          STDERR.puts "[deepl-cli] Detected source language: #{result_item.detected_source_language}"
        end
        output.puts result_item.text
      end

      if output_file = option.output_file
        File.open(output_file, "w") do |output_file_handle|
          output.to_s(output_file_handle)
        end
        STDERR.puts "[deepl-cli] Corrected text is written to #{output_file}"
      end
    end

    private def normalize_write_language(language : String?) : String?
      return unless language

      case language.upcase
      when "EN-GB"   then "en-GB"
      when "EN-US"   then "en-US"
      when "PT-BR"   then "pt-BR"
      when "PT-PT"   then "pt-PT"
      when "ZH-HANS" then "zh-Hans"
      else                language.downcase
      end
    end

    def translate_document
      raise "Invalid option: -i --input" unless option.input_text.empty?
      abort_with_help("Input file is not specified") if ARGV.empty?
      validate_translation_options
      validate_document_polling_options
      option.input_path = Path[ARGV.shift]
      case ARGV.size
      when 1
        STDERR.puts "[deepl-cli] File #{ARGV[0]} is ignored"
      when 2..
        STDERR.puts "[deepl-cli] Files #{ARGV.join(", ")} are ignored"
      end

      translator = DeepL::Translator.new
      handle_file = option.document_handle_file || default_document_handle_file
      remove_handle_file_after_download = option.document_handle_file.nil?
      check_document_handle_file_writable(handle_file)

      with_spinner do
        document_handle = upload_document(translator)

        save_document_handle_file(document_handle, handle_file)

        STDERR.puts avoid_spinner("[deepl-cli] Document uploaded")
        STDERR.puts avoid_spinner("[deepl-cli] File: #{option.input_path}")
        STDERR.puts avoid_spinner("[deepl-cli] ID: #{document_handle.id}")
        STDERR.puts avoid_spinner("[deepl-cli] Document handle: #{handle_file}")

        translator.translate_document_wait_until_done(
          handle: document_handle,
          interval: option.interval,
        ) do |document_status|
          STDERR.puts avoid_spinner("[deepl-cli] Status: #{document_status.status}")
          STDERR.puts avoid_spinner("[deepl-cli] Seconds Remaining: #{document_status.seconds_remaining}") if document_status.seconds_remaining
          STDERR.puts avoid_spinner("[deepl-cli] Billed Characters: #{document_status.billed_characters}") if document_status.billed_characters
          STDERR.puts avoid_spinner("[deepl-cli] Error Message: #{document_status.error_message}") if document_status.error_message
        end

        output_file = option.output_file || generate_document_output_file(option.input_path, option.target_lang, option.output_format)
        STDERR.puts avoid_spinner("[deepl-cli] Downloading translated document to #{output_file}")
        translator.translate_document_download(document_handle, output_file)
        STDERR.puts avoid_spinner("[deepl-cli] Document saved as #{output_file}")
        delete_document_handle_file(handle_file) if remove_handle_file_after_download
      end
    end

    private def validate_document_polling_options : Nil
      raise ArgumentError.new("Document polling interval must not be negative.") if option.interval < 0
    end

    def upload_document_to_translate
      raise "Invalid option: -i --input" unless option.input_text.empty?
      abort_with_help("Input file is not specified") if ARGV.empty?
      validate_translation_options
      option.input_path = Path[ARGV.shift]

      case ARGV.size
      when 1
        STDERR.puts "[deepl-cli] File #{ARGV[0]} is ignored"
      when 2..
        STDERR.puts "[deepl-cli] Files #{ARGV.join(", ")} are ignored"
      end

      translator = DeepL::Translator.new
      handle_file = option.document_handle_file || default_document_handle_file
      check_document_handle_file_writable(handle_file)

      document_handle = with_spinner do
        upload_document(translator)
      end

      STDERR.puts "[deepl-cli] Document uploaded"
      STDERR.puts "[deepl-cli] File: #{option.input_path}"
      STDERR.puts "[deepl-cli] ID: #{document_handle.id}"
      save_document_handle_file(document_handle, handle_file)
      STDERR.puts "[deepl-cli] Document handle: #{handle_file}"
      STDERR.puts "[deepl-cli] Use this file with 'deepl doc status --handle' and 'deepl doc download --handle'"
    end

    private def upload_document(translator : Translator) : DocumentHandle
      translator.translate_document_upload(
        path: option.input_path,
        target_lang: option.target_lang,
        source_lang: option.source_lang,
        formality: option.formality,
        glossary_id: option.glossary_id,
        glossary_name: option.glossary_name,
        output_format: option.output_format,
        glossary_ids: option.glossary_ids,
        enable_watermark: option.enable_watermark,
      )
    end

    private def validate_translation_options : Nil
      validate_glossary_options
    end

    private def validate_glossary_options : Nil
      glossary_ids = option.glossary_ids || option.glossary_id.try { |id| [id] }
      return unless glossary_ids

      raise ArgumentError.new("--glossary-id requires at least one glossary ID.") if glossary_ids.empty?
      raise ArgumentError.new("--glossary-id accepts at most 5 glossary IDs.") if glossary_ids.size > 5
      raise ArgumentError.new("--from is required with --glossary-id.") unless option.source_lang
      if option.glossary_name
        raise ArgumentError.new("--glossary-id cannot be combined with --glossary.")
      end
    end

    def check_document_translation_status
      translator = DeepL::Translator.new
      document_handle = document_handle_from_options
      status = translator.translate_document_get_status(document_handle)
      puts status.summary
    end

    def download_translated_document
      translator = DeepL::Translator.new
      output_file = option.output_file || raise "Output file is not specified"
      document_handle = document_handle_from_options
      translator.translate_document_download(document_handle, output_file)
    end

    private def default_document_handle_file : Path
      Path["#{option.input_path}.deepl-handle.json"]
    end

    private def generate_document_output_file(source_path : Path, target_lang : String, output_format : String?) : Path
      output_base_name = "#{source_path.stem}_#{target_lang}"
      output_extension = output_format ? ".#{output_format.downcase}" : source_path.extension
      ensure_unique_output_file(source_path.parent / (output_base_name + output_extension))
    end

    private def ensure_unique_output_file(output_file : Path) : Path
      return output_file unless File.exists?(output_file)

      output_base_name = "#{output_file.stem}_#{Time.utc.to_unix}"
      output_file.parent / (output_base_name + output_file.extension)
    end

    private def check_document_handle_file_writable(handle_file : Path) : Nil
      tmp = File.tempfile("deepl-handle", ".json", dir: handle_file.dirname)
      tmp.chmod(0o600)
    rescue ex
      raise "Cannot write document handle before upload: #{handle_file}\n" \
            "The document was not uploaded.\n" \
            "Use --handle FILE to choose a writable location.\n" \
            "#{ex.class}: #{ex.message}"
    ensure
      if tmp
        tmp_path = tmp.path
        tmp.close unless tmp.closed?
        File.delete?(tmp_path)
      end
    end

    private def save_document_handle_file(document_handle : DocumentHandle, handle_file : Path) : Nil
      write_document_handle_file(document_handle, handle_file)
    rescue ex
      raise "Failed to write document handle: #{handle_file}\n" \
            "The document was uploaded, but the key was not saved.\n" \
            "Use --handle FILE to choose a writable location.\n" \
            "#{ex.class}: #{ex.message}"
    end

    private def delete_document_handle_file(handle_file : Path) : Nil
      File.delete(handle_file)
    rescue ex
      raise "Failed to delete document handle: #{handle_file}\n" \
            "The translated document was downloaded, but the key file remains.\n" \
            "Delete it manually if you no longer need it.\n" \
            "#{ex.class}: #{ex.message}"
    end

    private def write_document_handle_file(document_handle : DocumentHandle, handle_file : Path) : Nil
      # Write to a temporary file in the same directory, then atomically rename
      # it into place. This keeps the handle file (which holds the secret key)
      # from ever being left truncated/partial, and avoids writing through a
      # symlink at the destination (rename replaces the symlink itself).
      tmp = File.tempfile("deepl-handle", ".json", dir: handle_file.dirname)
      begin
        tmp.chmod(0o600)
        JSON.build(tmp) do |json|
          json.object do
            json.field "document_id", document_handle.id
            json.field "document_key", document_handle.key
          end
        end
        tmp.puts
        tmp.flush
        tmp.close
        File.rename(tmp.path, handle_file)
      rescue ex
        File.delete?(tmp.path)
        raise ex
      ensure
        tmp.close unless tmp.closed?
      end
    end

    private def read_document_handle_file(handle_file : Path) : {String, String}
      json = JSON.parse(File.read(handle_file))
      {json["document_id"].as_s, json["document_key"].as_s}
    rescue ex
      raise "Failed to read document handle: #{handle_file}\n" \
            "The file is missing or not a valid handle file.\n" \
            "It should contain JSON with \"document_id\" and \"document_key\".\n" \
            "#{ex.class}: #{ex.message}"
    end

    private def document_handle_from_options : DocumentHandle
      if handle_file = option.document_handle_file
        document_id, document_key = read_document_handle_file(handle_file)
        DocumentHandle.new(document_id, document_key)
      else
        document_id = option.document_id || raise "Document ID is not specified"
        document_key = option.document_key || raise "Document key is not specified"
        DocumentHandle.new(document_id, document_key)
      end
    end

    def create_glossary
      # The glossary entry format is still inferred from the file extension.

      input_path = ARGV.size == 1 ? Path[ARGV[0]] : nil
      entry_format = glossary_entry_format(input_path)

      # Standard input is assumed to be TSV when no file name is available.

      if option.glossary_name.nil? && input_path
        option.glossary_name = input_path.stem
      end
      option.input_text = ARGF.gets_to_end

      translator = DeepL::Translator.new
      dict = DeepL::GlossaryDictionary.new(
        normalize_glossary_language(option.source_lang) || raise("Source language is required (-f)"),
        normalize_glossary_language(option.target_lang),
        option.input_text,
        entry_format
      )
      translator.create_multilingual_glossary(
        name: option.glossary_name || raise("Glossary name is required (-n)"),
        dictionaries: [dict]
      )

      STDERR.puts "[deepl-cli] Glossary #{option.glossary_name} is created"
    end

    private def glossary_entry_format(input_path : Path?) : String
      return "tsv" unless input_path

      case input_path.extension.downcase
      when ".csv"
        "csv"
      else
        "tsv"
      end
    end

    def argv_or_select_name_from_glossary_list
      if ARGV.size == 0
        if glossary_name = select_name_from_glossary_list
          [glossary_name]
        else
          [] of String
        end
      else
        ARGV
      end
    end

    def argv_or_select_id_from_glossary_list_long
      if ARGV.size == 0
        if glossary_id = select_id_from_glossary_list_long
          [glossary_id]
        else
          [] of String
        end
      else
        ARGV
      end
    end

    def select_name_from_glossary_list : String?
      prompt = Term::Prompt.new
      translator = DeepL::Translator.new
      glossary_list = translator.list_multilingual_glossaries
      return if glossary_list.empty?
      glossary_names = glossary_list.map(&.name)
      prompt.select("Select glossary", glossary_names)
    end

    def select_id_from_glossary_list_long : String?
      prompt = Term::Prompt.new
      translator = DeepL::Translator.new
      glossary_list = translator.list_multilingual_glossaries
      return if glossary_list.empty?
      max = glossary_list.max_of(&.name.size)
      glossary_str_list = glossary_list.map do |glossary_item|
        langs = glossary_item.dictionaries.map { |dictionary| "#{dictionary.source_lang} -> #{dictionary.target_lang}" }.join(", ")
        [
          glossary_item.name.rjust(max + 1),
          langs,
          glossary_item.creation_time,
          glossary_item.glossary_id,
        ].join("\t")
      end
      glossary_str = prompt.select("Select glossary", glossary_str_list)
      return unless glossary_str

      glossary_str.split("\t").last
    end

    def delete_glossary_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      glossary_names.each do |glossary_name|
        info = translator.find_multilingual_glossary_by_name(glossary_name)
        translator.delete_multilingual_glossary(info.glossary_id)
        STDERR.puts "[deepl-cli] Glossary #{glossary_name} is deleted"
      end
    end

    def delete_glossary_by_id
      glossary_ids = argv_or_select_id_from_glossary_list_long
      translator = DeepL::Translator.new
      glossary_ids.each do |glossary_id|
        info = translator.get_multilingual_glossary(glossary_id)
        translator.delete_multilingual_glossary(glossary_id)
        STDERR.puts "[deepl-cli] Glossary #{info.name} is deleted"
      end
    end

    def edit_glossary_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      glossary_names.each do |glossary_name|
        glossary_info = translator.find_multilingual_glossary_by_name(glossary_name)
        edit_glossary_core(translator, glossary_info)
      end
    end

    def edit_glossary_by_id
      glossary_ids = argv_or_select_id_from_glossary_list_long
      translator = DeepL::Translator.new
      glossary_ids.each do |glossary_id|
        glossary_info = translator.get_multilingual_glossary(glossary_id)
        edit_glossary_core(translator, glossary_info)
      end
    end

    def edit_glossary_core(translator, glossary_info)
      # Choose language pair
      src, tgt = resolve_or_select_language_pair(glossary_info)

      original_entries_text = with_spinner do
        dict = translator.get_multilingual_glossary_entries(glossary_info.glossary_id, src, tgt)
        dict.entries.to_s
      end

      edited_entries_text = Utils.edit_text(original_entries_text)

      # If the glossary is not changed, return
      return if original_entries_text.chomp == edited_entries_text.chomp

      # upload the edited dictionary for the selected language pair
      with_spinner do
        translator.put_multilingual_glossary_dictionary(
          glossary_id: glossary_info.glossary_id,
          source_lang: src,
          target_lang: tgt,
          entries: edited_entries_text,
          entries_format: "tsv"
        )
      end
      STDERR.puts("[deepl-cli] Glossary #{glossary_info.name} (#{src}->#{tgt}) is updated")
    end

    def output_glossary_entries_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      output_file = option.output_file
      File.delete?(output_file) if output_file
      glossary_names.each do |glossary_name|
        info = translator.find_multilingual_glossary_by_name(glossary_name)
        src, tgt = resolve_or_select_language_pair(info)
        dict = translator.get_multilingual_glossary_entries(info.glossary_id, src, tgt)
        entries_text = dict.entries.to_s
        if output_file
          File.write(output_file, entries_text, mode: "a")
          STDERR.puts "[deepl-cli] Glossary entries of #{glossary_name} are written to #{output_file}"
        else
          puts entries_text
        end
      end
    end

    def output_glossary_entries_by_id
      glossary_ids = argv_or_select_id_from_glossary_list_long
      translator = DeepL::Translator.new
      output_file = option.output_file
      File.delete?(output_file) if output_file
      glossary_ids.each do |glossary_id|
        info = translator.get_multilingual_glossary(glossary_id)
        src, tgt = resolve_or_select_language_pair(info)
        dict = translator.get_multilingual_glossary_entries(glossary_id, src, tgt)
        entries_text = dict.entries.to_s
        if output_file
          File.write(output_file, entries_text, mode: "a")
          STDERR.puts "[deepl-cli] Glossary entries of #{glossary_id} are written to #{output_file}"
        else
          puts entries_text
        end
      end
    end

    def print_glossary_list
      translator = DeepL::Translator.new
      glossary_list = translator.list_multilingual_glossaries
      return if glossary_list.empty?
      glossary_list.each do |glossary|
        puts glossary.name
      end
    end

    def print_glossary_list_long
      translator = DeepL::Translator.new
      glossary_list = translator.list_multilingual_glossaries
      return if glossary_list.empty?
      max = glossary_list.max_of(&.name.size)
      glossary_list.each do |glossary_item|
        langs = glossary_item.dictionaries.map { |dictionary| "#{dictionary.source_lang} -> #{dictionary.target_lang}" }.join(", ")
        puts [
          glossary_item.name.rjust(max + 1),
          langs,
          glossary_item.creation_time,
          glossary_item.glossary_id,
        ].join("\t")
      end
    end

    # Resolve language pair from options or interactively select from glossary dictionaries
    private def resolve_or_select_language_pair(glossary_info)
      src = option.source_lang
      tgt = option.target_lang
      if src && tgt
        return {normalize_glossary_language(src), normalize_glossary_language(tgt)}
      end
      prompt = Term::Prompt.new
      pairs = glossary_info.dictionaries.map { |dictionary| "#{dictionary.source_lang} -> #{dictionary.target_lang}" }
      selected = prompt.select("Select language pair", pairs) || raise "Selection cancelled"
      parts = selected.split(" -> ")
      {parts[0], parts[1]}
    end

    # The v3 multilingual glossary API accepts lowercase ISO language codes.
    private def normalize_glossary_language(language : String) : String
      language.downcase
    end

    private def normalize_glossary_language(language : Nil) : Nil
      nil
    end

    def print_source_languages
      translator = DeepL::Translator.new
      languages = translator.get_languages("translate_text").select(&.usable_as_source)
      print_langinfo(languages)
    end

    def print_target_languages
      translator = DeepL::Translator.new
      languages = translator.get_languages("translate_text").select(&.usable_as_target)
      default_target_language = Config.default_target_lang
      print_langinfo(languages, default: default_target_language)
    end

    private def print_langinfo(
      languages : Array(ResourceLanguage),
      default : String? = nil,
    ) : Nil
      languages.each do |info|
        abbrev = info.lang.upcase
        name = info.name
        row = String.build do |row_builder|
          row_builder << ((default && (default == abbrev)) ? "+ " : "- ")
          row_builder << "#{abbrev.ljust(7)}#{name.ljust(24)}"
          row_builder << "supports formality" if info.features.has_key?("formality")
        end
        puts row
      end
    end

    def print_usage
      translator = DeepL::Translator.new
      usage = translator.get_usage
      puts translator.server_url
      usage_values = JSON.parse(usage.to_json).as_h
      usage_field_names.each do |field|
        if value = usage_values[field]?
          puts "#{field}: #{value}" unless value.raw.nil?
        end
      end
      print_usage_products(usage) if usage.is_a?(UsagePro)
    end

    private def print_usage_products(usage : UsagePro, output : IO = STDOUT) : Nil
      return if usage.products.empty?

      output.puts "products:"
      usage.products.each_with_index do |product, index|
        output.puts "  product #{index + 1}:"
        if product_type = product.product_type
          output.puts "    product_type: #{product_type}"
        end
        if billing_unit = product.billing_unit
          output.puts "    billing_unit: #{billing_unit}"
        end
        if api_key_unit_count = product.api_key_unit_count
          output.puts "    api_key_unit_count: #{api_key_unit_count}"
        end
        if account_unit_count = product.account_unit_count
          output.puts "    account_unit_count: #{account_unit_count}"
        end
      end
    end

    private def usage_field_names : Array(String)
      [
        "character_count",
        "character_limit",
        "api_key_character_count",
        "api_key_character_limit",
        "document_count",
        "document_limit",
        "team_document_count",
        "team_document_limit",
        "speech_to_text_minutes_count",
        "speech_to_text_minutes_limit",
        "speech_to_speech_minutes_count",
        "speech_to_speech_minutes_limit",
        "speech_to_text_milliseconds_count",
        "speech_to_text_milliseconds_limit",
      ]
    end

    def print_version
      puts VERSION_STRING
    end

    def print_help
      puts parser.help_message
    end

    private def abort_with_help(message : String) : NoReturn
      STDERR.puts "\n[deepl-cli] ERROR: #{message}"
      STDERR.puts parser.help_message
      exit(1)
    end

    private def avoid_spinner(str)
      return str unless STDERR.tty?
      "\e[2K\r" + str
    end
  end
end
