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
      when Action::CreateGlossary
        create_glossary
      when Action::DeleteGlossary
        delete_glossary
      when Action::ListGlossaryLanguagePairs
        show_glossary_language_pairs
      when Action::ListGlossaries
        show_glossary_list
      when Action::OutputGlossaryEntries
        output_glossary_entries
      when Action::ListFromLanguages
        show_source_languages
      when Action::ListTargetLanguages
        show_target_languages
      when Action::RetrieveUsage
        show_usage
      when Action::Version
        show_version
      when Action::Help
        show_help
      else
        raise ArgumentError.new("Invalid action: #{option.action}")
      end
      # exit(0)
    rescue ex
      if DeepLError.debug
        STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}\n#{ex.backtrace.join("\n")}"
      else
        STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}"
      end
      exit(1)
    end

    def translate_text
      if option.input_text.empty?
        option.input_text = ARGF.gets_to_end
      end

      # Remove ANSI escape codes from input_text
      if option.no_ansi
        option.input_text = option.input_text.gsub(/\e\[[0-9;]*[mGKHF]/, "")
      end

      translated_text = ""

      spinner = Term::Spinner.new(clear: true)
      spinner.run do
        translator = DeepL::Translator.new
        translated_text = translator.translate(option)
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

      spinner = Term::Spinner.new(clear: true)
      spinner.run do
        translator = DeepL::Translator.new
        translator.translate(option)
      end
    end

    def show_glossary_language_pairs
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
      translator.create_glossary(option)
    end

    def delete_glossary
      translator = DeepL::Translator.new
      translator.delete_glossary(option)
    end

    def output_glossary_entries
      translator = DeepL::Translator.new
      puts translator.glossary_entries(ARGV[0])
    end

    def show_glossary_list
      translator = DeepL::Translator.new
      pp translator.glossary_list
    end

    def show_source_languages
      translator = DeepL::Translator.new
      translator.source_languages.each do |lang|
        language, name = lang.values.map(&.to_s)
        puts "- #{language.ljust(7)}#{name}"
      end
    end

    def show_target_languages
      translator = DeepL::Translator.new
      translator.target_languages.each do |lang|
        language, name, supports_formality = lang.values.map(&.to_s)
        formality = (supports_formality == "true") ? "yes" : "no"
        puts "- #{language.ljust(7)}#{name.ljust(20)}\tformality support [#{formality}]"
      end
    end

    def show_usage
      translator = DeepL::Translator.new
      puts translator.api_url_base
      puts translator.usage.map { |k, v| "#{k}: #{v}" }.join("\n")
    end

    def show_version
      puts DeepL::VERSION
    end

    def show_help
      puts parser
    end
  end
end
