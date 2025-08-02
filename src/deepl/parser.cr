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
      self.banner = "\n{{banner.id}}\n"
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

      separator "Commands:"

      on("text", "Translate text (default)") do
        # Reuse the options of the main command.
        opt.action = Action::TranslateText
        self.banner = <<-BANNER

          Usage: deepl text [options] <text>

        BANNER

        @handlers.reject! %w(-h --help -d --debug -v --version -u --usage)
        @flags.pop(4)

        on("-s", "--split-sentences OPT", "Split sentences") do |v|
          opt.split_sentences = v
        end

        on("-P", "--preserve-formatting", "Preserve formatting") do
          opt.preserve_formatting = true
        end

        on("-T", "--tag-handling OPT", "Tag handling") do |v|
          opt.tag_handling = v
        end

        on("-O", "--outline-detection", "Outline detection") do
          opt.outline_detection = true
        end

        on("-N", "--non-splitting-tags TAGS", "Non-splitting tags") do |tags|
          opt.non_splitting_tags = tags.split(",")
        end

        on("-S", "--splitting-tags TAGS", "Splitting tags") do |tags|
          opt.splitting_tags = tags.split(",")
        end

        on("-I", "--ignore-tags TAGS", "Ignore tags") do |tags|
          opt.ignore_tags = tags.split(",")
        end

        on("-M", "--model TYPE", "Model type") do |type|
          opt.model_type = type
        end

        # This option is useful for debugging.
        # on("--show-model-type", "Output model type used") do
        #   opt.show_model_type = true
        # end

        _on_debug_

        _on_help_
      end

      on("rephrase", "Rephrase text") do
        _set_action_(Action::RephraseText, "Usage: deepl rephrase [options] <text>")

        on("-i", "--input TEXT", "Input text") do |text|
          opt.input_text = text
        end

        on("-w", "--writing-style STYLE", "Writing style (academic, business, casual, default, simple)") do |style|
          opt.writing_style = style
        end

        on("-T", "--tone TONE", "Writing tone (confident, diplomatic, enthusiastic, friendly)") do |tone|
          opt.tone = tone
        end

        opt.target_lang = nil # AUTO

        on("-t", "--to [LANG]", "Target language [AUTO]") do |to_|
          opt.target_lang = to_.upcase
        end

        on("-D", "--detect-language", "Output detected source language") do
          opt.detect_source_language = true
        end

        on("-o", "--output FILE", "Output file") do |file|
          opt.output_file = Path[file]
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

        on("-A", "--ansi", "Do not remove ANSI escape codes") do
          opt.no_ansi = false
        end

        _on_debug_

        _on_help_
      end

      on("doc", "Translate document") do
        _set_action_(Action::TranslateDocument, "Usage: deepl doc [options] <file>")

        on("status", "Check translation status") do
          _set_action_(Action::TranslateDocumentStatus, "Usage: deepl doc status [options]")

          on("-i", "--id ID", "Document ID (required)") do |id|
            opt.document_id = id
          end

          on("-k", "--key KEY", "Document key (required)") do |key|
            opt.document_key = key
          end

          _on_debug_

          _on_help_
        end

        on("download", "Download translated document") do
          _set_action_(Action::TranslateDocumentDownload, "Usage: deepl doc download [options]")

          on("-i", "--id ID", "Document ID (required)") do |id|
            opt.document_id = id
          end

          on("-k", "--key KEY", "Document key (required)") do |key|
            opt.document_key = key
          end

          on("-o", "--output FILE", "Output file (required)") do |file|
            opt.output_file = Path[file]
          end

          _on_debug_

          _on_help_
        end

        separator

        on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
          opt.source_lang = from.upcase
        end

        on("-t", "--to [LANG]", "Target language [#{opt.target_lang}]") do |to_|
          opt.target_lang = to_.upcase
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

        on("-U", "--upload-only", "Upload file only") do
          opt.action = Action::TranslateDocumentUpload
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

          on("-n", "--name NAME", "Glossary name (required)") do |name|
            opt.glossary_name = name
          end

          on("-f", "--from LANG", "Source language (required)") do |from|
            opt.source_lang = from.upcase
          end

          on("-t", "--to LANG", "Target language [#{opt.target_lang}]") do |to_|
            opt.target_lang = to_.upcase
          end

          _on_debug_

          _on_help_
        end

        on("delete", "Delete glossaries") do
          _set_action_(Action::DeleteGlossaryByName, "Usage: deepl glossary delete <names>")

          on("-i", "--id", "Delete glossary by ids instead of names") do
            opt.action = Action::DeleteGlossaryById
          end

          _on_debug_

          _on_help_
        end

        on("edit", "Edit glossaries") do
          _set_action_(Action::EditGlossaryByName, "Usage: deepl glossary edit <names>")

          on("-i", "--id", "Edit glossary by ids instead of names") do
            opt.action = Action::EditGlossaryById
          end

          on("-e", "--editor EDITOR", "Editor command [ENV[\"EDITOR\"]]") do |editor|
            ENV["EDITOR"] = editor
          end

          _on_debug_

          _on_help_
        end

        on("view", "View glossaries") do
          _set_action_(Action::OutputGlossaryEntriesByName, "Usage: deepl glossary view <names>")

          on("-i", "--id", "View glossary by ids instead of names") do
            opt.action = Action::OutputGlossaryEntriesById
          end

          on("-o", "--output FILE", "Output file") do |file|
            opt.output_file = Path[file]
          end

          _on_debug_

          _on_help_
        end

        separator

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

      separator
      separator "Options:"

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

      on("-t", "--to [LANG]", "Target language [#{opt.target_lang}]") do |to_|
        if to_.empty?
          opt.action = Action::ListTargetLanguages
        else
          opt.target_lang = to_.upcase
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
        opt.detect_source_language = true
      end

      on("-B", "--show-billed-characters", "Output billed characters") do
        opt.show_billed_characters = true
      end

      on("-F", "--formality OPT", "Formality (default more less)") do |v|
        opt.formality = v
      end

      on("-C", "--context TEXT", "Context (experimental)") do |text|
        opt.context = text
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
