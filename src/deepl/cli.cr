require "../ext/crest"
require "deepl/translator"
require "term-prompt"
require "term-spinner"
require "./parser"
require "./utils"

module DeepL
  class CLI
    class_property debug : Bool = false
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
      when Action::TranslateDocument
        translate_document
      when Action::TranslateDocumentUpload
        upload_document_to_translate
      when Action::TranslateDocumentStatus
        check_document_translation_status
      when Action::TranslateDocumentDownload
        download_translated_document
      when Action::ListGlossaryLanguagePairs
        print_glossary_language_pairs
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
        print_help
      else
        raise ArgumentError.new("Invalid action: #{option.action}")
      end
    rescue ex
      error_message = "\n[deepl-cli] ERROR: #{ex.class} #{ex.message}"
      error_message += "\n#{ex.response}" if ex.is_a?(Crest::RequestFailed)
      error_message += "\n#{ex.backtrace.join("\n")}" if CLI.debug
      STDERR.puts error_message
      exit(1)
    end

    private def with_spinner(&block)
      result = nil
      spinner = Term::Spinner.new(clear: true)
      spinner.run do
        result = block.call
      end
      return result
    end

    private def remove_ansi_escape_codes(text)
      # gsub(/\e\[[0-9;]*[mGKHF]/, "")
      # The above regular expression used to be used.
      # However, it is insufficient because it cannot remove bold and other characters.
      #
      # How can I remove the ANSI escape sequences from a string in python
      # https://stackoverflow.com/questions/14693701
      # Python regular expressions were converted for PCRE2 using ChatGPT.
      ansi_escape_8bit = Regex.new(
        "(?:\x1B[@-Z\\-_]|[\\x80-\\x9A\\x9C-\\x9F]|(?:\x1B\\[|\\x9B)[0-?]*[ -/]*[@-~])"
      )
      text.gsub(ansi_escape_8bit, "")
    end

    def translate_text
      if option.input_text.empty?
        option.input_text = ARGF.gets_to_end
      end

      # Remove ANSI escape codes from the input text
      option.input_text = remove_ansi_escape_codes(option.input_text)

      result = [] of DeepL::TextResult
      translator = DeepL::Translator.new

      with_spinner do
        result = translator.translate_text(
          text: option.input_text,
          target_lang: option.target_lang,
          source_lang: option.source_lang,
          formality: option.formality,
          split_sentences: option.split_sentences,
          preserve_formatting: option.preserve_formatting,
          tag_handling: option.tag_handling,
          outline_detection: option.outline_detection,
          non_splitting_tags: option.non_splitting_tags,
          splitting_tags: option.splitting_tags,
          ignore_tags: option.ignore_tags,
          glossary_name: option.glossary_name, # original option of deepl.cr
          context: option.context,
          show_billed_characters: option.show_billed_characters,
          model_type: option.model_type
        )
      end

      output = option.output_file ? IO::Memory.new : STDOUT

      result.each do |r|
        if option.detect_source_language
          STDERR.puts "[deepl-cli] Detected source language: #{r.detected_source_language}"
        end
        if option.show_billed_characters
          STDERR.puts "[deepl-cli] Billed characters: #{r.billed_characters}"
        end
        # if option.show_model_type && r.model_type_used
        #   STDERR.puts "[deepl-cli] Model type used: #{r.model_type_used}"
        # end
        output.puts r.text
      end
      if output_file = option.output_file
        File.open(output_file, "w") { |f| output.to_s(f) }
        STDERR.puts "[deepl-cli] Translated text is written to #{output_file}"
      end
    end

    def translate_document
      raise "Invalid option: -i --input" unless option.input_text.empty?
      raise "Input file is not specified" if ARGV.empty?
      option.input_path = Path[ARGV.shift]
      case ARGV.size
      when 1
        STDERR.puts "[deepl-cli] File #{ARGV[0]} is ignored"
      when 2..
        STDERR.puts "[deepl-cli] Files #{ARGV.join(", ")} are ignored"
      end

      translator = DeepL::Translator.new

      with_spinner do
        translator.translate_document(
          path: option.input_path,
          target_lang: option.target_lang,
          source_lang: option.source_lang,
          formality: option.formality,
          glossary_name: option.glossary_name, # original option of deepl.cr
          output_format: option.output_format,
          output_file: option.output_file,
          interval: option.interval,
          message_prefix: "[deepl-cli] "
        ) do |progress|
          STDERR.puts avoid_spinner(progress)
        end
      end
    end

    def upload_document_to_translate
      raise NotImplementedError.new("This action is not implemented yet")
    end

    def check_document_translation_status
      translator = DeepL::Translator.new
      if option.document_id.nil? || option.document_key.nil?
        raise "Document ID or key is not specified"
      end
      document_id = option.document_id.not_nil!
      document_key = option.document_key.not_nil!
      document_handle = DocumentHandle.new(document_id, document_key)
      status = translator.translate_document_get_status(document_handle)
      puts status
    end

    def download_translated_document
      translator = DeepL::Translator.new
      if option.document_id.nil? || option.document_key.nil?
        raise "Document ID or key is not specified"
      end
      if option.output_file.nil?
        raise "Output file is not specified"
      end
      document_id = option.document_id.not_nil!
      document_key = option.document_key.not_nil!
      output_file = option.output_file.not_nil!
      document_handle = DocumentHandle.new(document_id, document_key)
      translator.translate_document_download(document_handle, output_file)
    end

    def print_glossary_language_pairs
      translator = DeepL::Translator.new
      previous_source_lang = ""
      pairs = translator.get_glossary_language_pairs
      puts "Supported glossary language pairs"
      pairs.each do |pair|
        source_lang = pair.source_lang
        target_lang = pair.target_lang
        if source_lang != previous_source_lang
          puts if previous_source_lang != ""
          print "- #{source_lang} :\t"
          previous_source_lang = source_lang
        end
        print " #{target_lang}"
      end
      puts
    end

    def create_glossary
      # FIXME check TSV file format

      entry_format = "tsv"

      # A corner case still not handled:
      # Standard input is CSV file format

      if option.glossary_name.nil? && ARGV.size == 1
        name = ARGV[0]
        entry_format = File.extname(name).sub(".", "").downcase
        name = File.basename(name, File.extname(name))
        option.glossary_name = name
      end
      option.input_text = ARGF.gets_to_end

      translator = DeepL::Translator.new
      translator.create_glossary(
        name: option.glossary_name,
        source_lang: option.source_lang,
        target_lang: option.target_lang,
        entries: option.input_text,
        entry_format: entry_format
      )

      STDERR.puts "[deepl-cli] Glossary #{option.glossary_name} is created"
    end

    def argv_or_select_name_from_glossary_list
      if ARGV.size == 0
        glossary_name = select_name_from_glossary_list.not_nil!
        [glossary_name]
      else
        ARGV
      end
    end

    def argv_or_select_id_from_glossary_list_long
      if ARGV.size == 0
        glossary_id = select_id_from_glossary_list_long.not_nil!
        glossary_ids = [glossary_id]
      else
        ARGV
      end
    end

    def select_name_from_glossary_list : String?
      prompt = Term::Prompt.new
      translator = DeepL::Translator.new
      glossary_list = translator.list_glossaries
      return if glossary_list.empty?
      glossary_names = glossary_list.map { |g| g.name }
      glossary_name = prompt.select("Select glossary", glossary_names)
    end

    def select_id_from_glossary_list_long : String?
      prompt = Term::Prompt.new
      translator = DeepL::Translator.new
      glossary_list = translator.list_glossaries
      return if glossary_list.empty?
      max = glossary_list.map { |g| g.name.size }.max.not_nil!
      glossary_str_list = glossary_list.map do |glossary|
        [
          glossary.name.rjust(max + 1),
          "#{glossary.source_lang} -> #{glossary.target_lang}",
          glossary.entry_count,
          glossary.creation_time,
          glossary.glossary_id,
        ].join("\t")
      end
      glossary_str = prompt.select("Select glossary", glossary_str_list)
      glossary_id = glossary_str.not_nil!.split("\t").last
    end

    def delete_glossary_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      glossary_names.each do |glossary_name|
        translator.delete_glossary_by_name(glossary_name)
        STDERR.puts "[deepl-cli] Glossary #{glossary_name} is deleted"
      end
    end

    def delete_glossary_by_id
      glossary_ids = argv_or_select_id_from_glossary_list_long
      translator = DeepL::Translator.new
      glossary_ids.each do |glossary_id|
        info = translator.get_glossary_info(glossary_id)
        translator.delete_glossary(glossary_id)
        STDERR.puts "[deepl-cli] Glossary #{info.name} is deleted"
      end
    end

    def edit_glossary_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      glossary_names.each do |glossary_name|
        glossary_info_list = translator.get_glossary_info_by_name(glossary_name)
        # FIXME
        case glossary_info_list.size
        when 2..
          creation_times = glossary_info_list.map { |g| g.creation_time.to_local.to_s }
          prompt = Term::Prompt.new
          tm = prompt.select("Select creation date", creation_times)
          glossary_info = glossary_info_list.find { |g| g.creation_time.to_local.to_s == tm }
          if glossary_info.nil?
            STDERR.puts "[deepl-cli] Glossary #{glossary_name} #{tm} is not found"
          else
            edit_glossary_core(translator, glossary_info)
          end
        when 1
          glossary_info = glossary_info_list.first
          edit_glossary_core(translator, glossary_info)
        when 0
        end
      end
    end

    def edit_glossary_by_id
      glossary_ids = argv_or_select_id_from_glossary_list_long
      translator = DeepL::Translator.new
      glossary_ids.each do |glossary_id|
        glossary_info = translator.get_glossary_info(glossary_id)
        edit_glossary_core(translator, glossary_info)
      end
    end

    def edit_glossary_core(translator, glossary_info)
      original_entries_text = ""
      with_spinner do
        original_entries_text = translator.get_glossary_entries(glossary_info.glossary_id)
      end

      edited_entries_text = Utils.edit_text(original_entries_text)

      # If the glossary is not changed, return
      return if original_entries_text.chomp == edited_entries_text.chomp

      # validate glossary
      # validate_glossary(entries_text)

      # upload the edited glossary
      with_spinner do
        translator.create_glossary(
          name: glossary_info.name,
          source_lang: glossary_info.source_lang,
          target_lang: glossary_info.target_lang,
          entries: edited_entries_text,
          entry_format: "tsv"
        )
        translator.delete_glossary(glossary_info.glossary_id)
      end
      STDERR.puts("[deepl-cli] Glossary #{glossary_info.name} is updated")
    end

    def output_glossary_entries_by_name
      glossary_names = argv_or_select_name_from_glossary_list
      translator = DeepL::Translator.new
      output_file = option.output_file
      File.delete(output_file) if output_file && File.exists?(output_file)
      glossary_names.each do |glossary_name|
        entries_text = translator.get_glossary_entries_by_name(glossary_name)
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
      File.delete(output_file) if output_file && File.exists?(output_file)
      glossary_ids.each do |glossary_id|
        entries_text = translator.get_glossary_entries(glossary_id)
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
      glossary_list = translator.list_glossaries
      return if glossary_list.empty?
      glossary_list.each do |glossary|
        puts glossary.name
      end
    end

    def print_glossary_list_long
      translator = DeepL::Translator.new
      glossary_list = translator.list_glossaries
      return if glossary_list.empty?
      max = glossary_list.map { |g| g.name.size }.max.not_nil!
      glossary_list.each do |glossary|
        puts [
          glossary.name.rjust(max + 1),
          "#{glossary.source_lang} -> #{glossary.target_lang}",
          glossary.entry_count,
          glossary.creation_time,
          glossary.glossary_id,
        ].join("\t")
      end
    end

    def print_source_languages
      translator = DeepL::Translator.new
      langinfo = translator.get_source_languages
      print_langinfo(langinfo)
    end

    def print_target_languages
      translator = DeepL::Translator.new
      langinfo = translator.get_target_languages
      default_target_language = Config.target_lang
      print_langinfo(langinfo, default: default_target_language)
    end

    private def print_langinfo(
      langinfo : Array(LanguageInfo),
      default : String? = nil,
    ) : Nil
      langinfo.each do |info|
        abbrev = info.language
        name = info.name
        formality = info.supports_formality
        row = String.build { |s|
          s << ((default && (default == abbrev)) ? "+ " : "- ")
          s << "#{abbrev.ljust(7)}#{name.ljust(24)}"
          s << "supports formality" if formality
        }
        puts row
      end
    end

    def print_usage
      translator = DeepL::Translator.new
      puts translator.server_url
      puts translator.get_usage.map { |k, v| "#{k}: #{v}" }.join("\n")
    end

    def print_version
      puts VERSION_STRING
    end

    def print_help
      puts parser.help_message
    end

    private def avoid_spinner(str)
      return str unless STDERR.tty?
      "#{"\e[2K\r" if STDERR.tty?}" + str
    end
  end
end
