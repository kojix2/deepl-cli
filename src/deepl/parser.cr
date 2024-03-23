require "option_parser"
require "./options"
require "./translator"

module DeepL
  class Parser < OptionParser
    getter opt : Options

    def initialize
      super()
      @opt = Options.new
      self.banner = <<-BANNER

        Program: DeepL CLI (Simple command line tool for DeepL)
        Version: #{DeepL::VERSION}
        Source:  https://github.com/kojix2/deepl-cli

        Usage: deepl [options] <file>
        BANNER
      on("doc", "Translate document") do
        opt.action = Action::Document
      end
      on("-i", "--input TEXT", "Input text") do |text|
        opt.input = text
      end
      on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
        from.empty? ? opt.action = Action::FromLang : opt.source_lang = from.upcase
      end
      on("-t", "--to [LANG]", "Target language [EN]") do |to|
        to.empty? ? opt.action = Action::ToLang : opt.target_lang = to.upcase
      end
      on("-g", "--glossary ID", "Glossary ID") do |id|
        opt.glossary_id = id
      end
      on("-F", "--formality OPT", "Formality (default more less)") do |v|
        opt.formality = v
      end
      on("-C", "--context TEXT", "Context (experimental)") do |text|
        opt.context = text
      end
      on("-S", "--split-sentences OPT", "Split sentences") do |v|
        opt.split_sentences = v
      end
      on("-A", "--ansi", "Do not remove ANSI escape codes") do
        opt.no_ansi = false
      end
      on("-u", "--usage", "Check Usage and Limits") do
        opt.action = Action::Usage
      end
      on("-d", "--debug", "Show backtrace on error") do
        DeepLError.debug = true
      end
      on("-v", "--version", "Show version") do
        opt.action = Action::Version
      end
      on("-h", "--help", "Show this help") do
        opt.action = Action::Help
      end
      invalid_option do |flag|
        STDERR.puts "[deepl-cli] ERROR: #{flag} is not a valid option."
        STDERR.puts self
        exit(1)
      end
    end

    def parse(args)
      super
      opt
    end
  end
end
