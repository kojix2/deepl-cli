require "term-spinner"
require "./parser"
require "./translator"
require "./exceptions"

module DeepL
  class App
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
      when Action::ListGlossaryLanguagePairs
        print_glossary_language_pairs
      when Action::CreateGlossary
        create_glossary
      when Action::DeleteGlossary
        delete_glossary
      when Action::ListGlossaries
        print_glossary_list
      when Action::OutputGlossaryEntries
        output_glossary_entries
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
      if DeepLError.debug
        STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}\n#{ex.backtrace.join("\n")}"
      else
        STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}"
      end
      exit(1)
    end

    private def with_spinner(&block)
      spinner = Term::Spinner.new(clear: true)
      spinner.run do
        block.call
      end
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

      option.input_text = remove_ansi_escape_codes(option.input_text)

      translated_text = ""

      with_spinner do
        translator = DeepL::Translator.new
        translated_text = translator.translate_text(
          option.input_text, option.target_lang, option.source_lang,
          option.formality, option.glossary_id, option.context
        )
      end

      puts translated_text
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
      STDERR.puts "[deepl-cli] Start translating #{option.input_path}"

      with_spinner do
        translator = DeepL::Translator.new
        translator.translate_document(
          option.input_path, option.target_lang, option.source_lang,
          option.formality, option.glossary_id, option.output_format,
          option.output_path
        )
      end
    end

    def print_glossary_language_pairs
      translator = DeepL::Translator.new
      previous_source_lang = ""
      translator.glossary_language_pairs.each do |kv|
        source_lang, target_lang = kv.values.map(&.to_s)
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
      option.input_text = ARGF.gets_to_end

      translator = DeepL::Translator.new
      translator.create_glossary(
        option.glossary_name, option.source_lang, option.target_lang,
        option.input_text
      )
    end

    def delete_glossary
      translator = DeepL::Translator.new
      translator.delete_glossary(option.glossary_id.not_nil!)
    end

    def output_glossary_entries
      translator = DeepL::Translator.new
      glossary_id = option.glossary_id
      glossary_name = option.glossary_name

      if glossary_id && glossary_name
        raise DeepLError.new("Glossary ID and Glossary Name are specified at the same time")
      elsif glossary_id.nil? && glossary_name.nil?
        raise DeepLError.new("Glossary ID or Glossary Name is not specified")
      elsif glossary_id
        puts translator.glossary_entries_from_id(glossary_id)
      elsif glossary_name
        puts translator.glossary_entries_from_name(glossary_name)
      end
    end

    def print_glossary_list
      translator = DeepL::Translator.new
      pp translator.glossary_list
    end

    def print_source_languages
      translator = DeepL::Translator.new
      translator.source_languages.each do |lang|
        language, name = lang.values.map(&.to_s)
        puts "- #{language.ljust(7)}#{name}"
      end
    end

    def print_target_languages
      translator = DeepL::Translator.new
      translator.target_languages.each do |lang|
        language, name, supports_formality = lang.values.map(&.to_s)
        formality = (supports_formality == "true") ? "yes" : "no"
        puts "- #{language.ljust(7)}#{name.ljust(20)}\tformality support [#{formality}]"
      end
    end

    def print_usage
      translator = DeepL::Translator.new
      puts translator.api_url_base
      puts translator.usage.map { |k, v| "#{k}: #{v}" }.join("\n")
    end

    def print_version
      puts DeepL::VERSION
    end

    def print_help
      puts parser.help_message
    end
  end
end
