require "option_parser"
require "./options"
require "./translator"

module DeepL
  class Parser < OptionParser
    getter opt : Options

    # Crystal's OptionParser returns to its initial state after parsing
    # by `with_preserved_state`. This also initialises @flags.
    # @help_message is needed to store subcommand messages.
    property help_message : String

    macro _on_debug_
      on("-d", "--debug", "Show backtrace on error") do
        DeepLError.debug = true
      end
    end

    macro _on_help_
      on("-h", "--help", "Show this help") do
        opt.action = Action::Help
        self.help_message = self.to_s
      end
    end

    def initialize
      super()
      @opt = Options.new
      @help_message = ""

      self.banner = <<-BANNER

        Program: DeepL CLI (Simple command line tool for DeepL)
        Version: #{DeepL::VERSION}
        Source:  https://github.com/kojix2/deepl-cli

        Usage: deepl [options] <file>
        BANNER

      on("doc", "Translate document") do
        opt.action = Action::TranslateDocument
        @handlers.clear
        @flags.clear
        self.banner = "Usage: deepl doc [options] <file>"

        on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
          opt.source_lang = from.upcase
        end

        on("-t", "--to [LANG]", "Target language [EN]") do |to|
          opt.target_lang = to.upcase
        end

        on("-g", "--glossary ID", "Glossary ID") do |id|
          opt.glossary_id = id
        end

        on("-F", "--formality OPT", "Formality (default more less)") do |v|
          opt.formality = v
        end

        on("-o", "--output FILE", "Output file") do |file|
          opt.output_path = Path[file]
        end

        on("-O", "--output-format FORMAT", "Output file format") do |format|
          opt.output_format = format
        end

        _on_debug_

        _on_help_
      end

      on("glossary", "Manage glossaries") do
        @opt.action = Action::OutputGlossaryEntries
        self.banner = "Usage: deepl glossary [options] <file>"
        @handlers.clear
        @flags.clear

        on("create", "Create glossary") do |name|
          opt.action = Action::CreateGlossary
          self.banner = "Usage: deepl glossary create [options]"
          @handlers.clear
          @flags.clear

          on("-n", "--name NAME", "Glossary name") do |name|
            opt.glossary_name = name
          end

          on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
            opt.source_lang = from.upcase
          end

          on("-t", "--to [LANG]", "Target language [EN]") do |to|
            opt.target_lang = to.upcase
          end

          _on_debug_

          _on_help_
        end

        on("list", "List glossaries") do
          opt.action = Action::ListGlossaries
          self.banner = "Usage: deepl glossary list [options]"
          @handlers.clear
          @flags.clear

          _on_debug_

          _on_help_
        end

        on("delete", "Delete glossary") do
          opt.action = Action::DeleteGlossary
          self.banner = "Usage: deepl glossary delete [options]"
          @handlers.clear
          @flags.clear

          on("-g", "--glossary ID", "Delete glossary by ID") do |id|
            opt.glossary_id = id
          end

          on("-d", "--debug", "Show backtrace on error") do
            DeepLError.debug = true
          end

          on("-h", "--help", "Show this help") do
            opt.action = Action::Help
            self.help_message = self.to_s
          end

          # on("-n", "--name
        end

        on("-l", "--list", "List glossaries (short form)") do
          opt.action = Action::ListGlossaries
          # FIXME: short form
        end

        on("-p", "--language-pairs", "List language pairs") do
          opt.action = Action::ListGlossaryLanguagePairs
        end

        _on_debug_

        _on_help_
      end

      on("-i", "--input TEXT", "Input text") do |text|
        opt.input_text = text
      end

      on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
        if from.empty?
          opt.action = Action::ListFromLanguages
        else
          opt.source_lang = from.upcase
        end
      end

      on("-t", "--to [LANG]", "Target language [EN]") do |to|
        if to.empty?
          opt.action = Action::ListTargetLanguages
        else
          opt.target_lang = to.upcase
        end
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

      _on_debug_

      on("-v", "--version", "Show version") do
        opt.action = Action::Version
      end

      _on_help_

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
