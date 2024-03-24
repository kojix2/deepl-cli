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
        opt.action = Action::TranslateDocument
        disabled_options = [
          "-i", "--input",
          "-C", "--context",
          "-S", "--split-sentences",
          "-A", "--ansi",
          "-u", "--usage",
          "-v", "--version",
          "-h", "--help",
        ]
        disabled_options.each { |o| @handlers.delete(o) }
        @flags.reject! { |f| disabled_options.any? { |o| f.includes?(o) } }

        self.banner = "Usage: deepl doc [options] <file>"

        on("-o", "--output FILE", "Output file") do |file|
          opt.output_path = Path[file]
        end

        on("-F", "--format FORMAT", "Output file format") do |format|
          opt.output_format = format
        end

        on("-h", "--help", "Show this help") do
          # FIXME
          puts self
        end
      end
      on("glossary", "Manage glossaries") do
        @opt.action = Action::OutputGlossaryEntries
        disabled_options = [
          "-i", "--input",
          "-f", "--from",
          "-t", "--to",
          "-F", "--formality",
          "-C", "--context",
          "-S", "--split-sentences",
          "-A", "--ansi",
          "-u", "--usage",
          "-v", "--version",
          "-h", "--help",
        ]
        disabled_options.each { |o| @handlers.delete(o) }
        @flags.reject! { |f| disabled_options.any? { |o| f.includes?(o) } }

        self.banner = "Usage: deepl glossary [options] <file>"

        on("create", "Create glossary") do |name|
          opt.action = Action::CreateGlossary
          disabled_options = [
            "-g", "--glossary",
            "-d", "--debug",
            "-l", "--list",
            "-p", "--language-pairs",
            "-h", "--help",
          ]
          disabled_options.each { |o| @handlers.delete(o) }
          @flags.reject! { |f| disabled_options.any? { |o| f.includes?(o) } }
          on("-n", "--name NAME", "Glossary name") do |name|
            opt.glossary_name = name
          end
          on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
            from.empty? ? opt.action = Action::ListFromLanguages : opt.source_lang = from.upcase
          end
          on("-t", "--to [LANG]", "Target language [EN]") do |to|
            to.empty? ? opt.action = Action::ListTargetLanguages : opt.target_lang = to.upcase
          end
          on("-h", "--help", "Show this help") do
            # FIXME
            puts self
          end
        end

        on("-l", "--list", "List glossaries") do
          opt.action = Action::ListGlossaries
        end

        on("-D", "--delete ID", "Delete glossary") do |id|
          opt.action = Action::DeleteGlossary
          opt.glossary_id = id
        end

        on("-p", "--language-pairs", "List language pairs") do
          opt.action = Action::ListGlossaryLanguagePairs
        end

        on("-h", "--help", "Show this help") do
          # FIXME
          puts self
        end
      end
      on("-i", "--input TEXT", "Input text") do |text|
        opt.input_text = text
      end
      on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
        from.empty? ? opt.action = Action::ListFromLanguages : opt.source_lang = from.upcase
      end
      on("-t", "--to [LANG]", "Target language [EN]") do |to|
        to.empty? ? opt.action = Action::ListTargetLanguages : opt.target_lang = to.upcase
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
        opt.action = Action::RetrieveUsage
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
