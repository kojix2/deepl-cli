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
      when Action::Text
        translate_text
      when Action::Document
        translate_document
      when Action::FromLang
        show_source_languages
      when Action::ToLang
        show_target_languages
      when Action::Usage
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
