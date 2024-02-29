require "option_parser"
require "./options"
require "./translator"

module Deepl
  class Parser < OptionParser
    getter opt : Options
    getter translator : Translator

    def initialize(translator)
      super()
      @opt = Options.new
      @translator = translator
      self.banner = "Usage: deepl [arguments]"
      on("doc", "Upload and translate a document") do
        opt.sub_command = SubCmd::Document
      end
      on("-i", "--input [TEXT]", "Input text") do |text|
        opt.input = text
      end
      on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
        show_source_languages if from.empty?
        opt.source_lang = from.upcase
      end
      on("-t", "--to [LANG]", "Target language [EN]") do |to|
        show_target_languages if to.empty?
        opt.target_lang = to.upcase
      end
      on("-g ID", "--glossary ID", "Glossary ID") do |id|
        opt.glossary_id = id
      end
      on("-u", "--usage", "Check Usage and Limits") do
        show_usage
      end
      on("-v", "--version", "Show version") do
        show_version
      end
      on("-h", "--help", "Show this help") do
        show_help
      end
      invalid_option do |flag|
        STDERR.puts "ERROR: #{flag} is not a valid option."
        STDERR.puts self
        exit(1)
      end
    end

    def parse(args)
      super
      opt
    end

    def show_source_languages
      translator.source_languages.each do |lang|
        language, name = lang.values.map(&.to_s)
        puts "- #{language.ljust(7)}#{name}"
      end
      exit
    end

    def show_target_languages
      translator.target_languages.each do |lang|
        language, name, supports_formality = lang.values.map(&.to_s)
        puts "- #{language.ljust(7)}#{name.ljust(20)}\t#{supports_formality}"
      end
      exit
    end

    def show_usage
      puts Translator::API_URL_BASE
      puts translator.usage.map { |k, v| "#{k}: #{v}" }.join("\n")
      exit
    end

    def show_version
      puts Deepl::VERSION
      exit
    end

    def show_help
      puts self
      exit
    end
  end
end
