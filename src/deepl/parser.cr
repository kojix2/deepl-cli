require "easyclip"
require "option_parser"
require "./options"
require "./cli/version"

module DeepL
  class Parser < OptionParser
    getter opt : Options

    property help_message : String

    macro _on_debug_
      on("-d", "--debug", "Show backtrace on error") do
        CLI.debug = true
      end
    end

    macro _on_help_
      on("-h", "--help", "Show this help") do
        opt.action = Action::Help
      end

      # Crystal's OptionParser returns to its initial state after parsing
      # by `with_preserved_state`. This also initialises @flags.
      # @help_message is needed to store subcommand messages.
      @help_message = self.to_s
    end

    macro _set_action_(action, banner)
      opt.action = {{action}}
      @handlers.clear
      @flags.clear
      self.banner = {{banner}}
    end

    def initialize
      super()
      @opt = Options.new
      @help_message = ""

      self.banner = <<-BANNER

        Program: DeepL CLI (Simple command line tool for DeepL)
        Version: #{DeepL::CLI::VERSION}
        Source:  https://github.com/kojix2/deepl-cli

        Usage: deepl [options] <file>
        BANNER

      on("doc", "Translate document") do
        _set_action_(Action::TranslateDocument, "Usage: deepl doc [options] <file>")

        on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
          opt.source_lang = from.upcase
        end

        on("-t", "--to [LANG]", "Target language [#{opt.target_lang}]") do |to|
          opt.target_lang = to.upcase
        end

        on("-g", "--glossary NAME", "Glossary name") do |name|
          opt.glossary_name = name
        end

        on("-F", "--formality OPT", "Formality (default more less)") do |v|
          opt.formality = v
        end

        on("-o", "--output FILE", "Output file") do |file|
          opt.output_file = Path[file]
        end

        on("-O", "--output-format FORMAT", "Output file format") do |format|
          opt.output_format = format
        end

        on("-s", "--interval SEC", "Interval between requests") do |sec|
          opt.interval = sec.to_f32
        end

        _on_debug_

        _on_help_
      end

      on("glossary", "Manage glossaries") do
        _set_action_(Action::Help, "Usage: deepl glossary [options] <subcommand>")

        on("list", "List glossaries") do
          _set_action_(Action::ListGlossariesLong, "Usage: deepl glossary list [options]")

          _on_debug_

          _on_help_
        end

        on("create", "Create a glossary") do |name|
          _set_action_(Action::CreateGlossary, "Usage: deepl glossary create [options] <tsv|csv>")

          on("-n", "--name NAME", "Glossary name") do |name|
            opt.glossary_name = name
          end

          on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
            opt.source_lang = from.upcase
          end

          on("-t", "--to [LANG]", "Target language [#{opt.target_lang}]") do |to|
            opt.target_lang = to.upcase
          end

          _on_debug_

          _on_help_
        end

        on("delete", "Delete a glossary") do
          _set_action_(Action::DeleteGlossary, "Usage: deepl glossary delete <name>")

          _on_debug_

          _on_help_
        end

        on("edit", "Edit a glossary") do
          _set_action_(Action::EditGlossary, "Usage: deepl glossary edit <name>")

          _on_debug_

          _on_help_
        end

        on("view", "View a glossary") do
          _set_action_(Action::OutputGlossaryEntries, "Usage: deepl glossary view <name>")

          # on("-i", "--id ID", "Delete glossary by Glossary ID") do |id|
          #   opt.glossary_id = id
          # end

          on("-o", "--output FILE", "Output file") do |file|
            opt.output_file = Path[file]
          end

          _on_debug_

          _on_help_
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

      on("text", "Translate text (default)") do
        opt.action = Action::TranslateText
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

      on("-t", "--to [LANG]", "Target language [#{opt.target_lang}]") do |to|
        if to.empty?
          opt.action = Action::ListTargetLanguages
        else
          opt.target_lang = to.upcase
        end
      end

      on("-p", "--paste", "Input text from clipboard") do
        text = EasyClip.paste
        if text.empty?
          STDERR.puts "[deepl-cli] ERROR: Clipboard is empty."
          exit(1)
        end
        STDERR.puts "[deepl-cli] Input text from clipboard: \n#{text}\n\n"
        opt.input_text = text
      end

      # FIXME: This option is experimental.
      # The name of the option may change in the future.
      # on("-c", "--copy", "Copy translated text to clipboard (experimental)") do
      #   # TODO?
      # end

      on("-g", "--glossary NAME", "Glossary name") do |name|
        opt.glossary_name = name
      end

      on("-D", "--detect-language", "Output detected source language") do
        opt.detect_source_lanuage = true
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

      # Why is --output option is needed?
      # Because utf-8 is not fully supported in Windows console.

      on("-o", "--output FILE", "Output file") do |file|
        opt.output_file = Path[file]
      end

      on("-u", "--usage", "Check Usage and Limits") do
        opt.action = Action::RetrieveUsage
        # @handlers.clear
        # @flags.clear
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

      missing_option do |flag|
        STDERR.puts "[deepl-cli] ERROR: #{flag} option expects an argument."
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
