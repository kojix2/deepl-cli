require "option_parser"
require "term-spinner"

require "./deepl/translator"
require "./deepl/parser"
require "./deepl/version"

module DeepL
  def self.run
    translator = DeepL::Translator.new
    parser = DeepL::Parser.new(translator)
    option = parser.parse(ARGV)

    if option.input.empty?
      option.input = ARGF.gets_to_end
    end

    # Remove ANSI escape codes from input
    if option.no_ansi
      option.input = option.input.gsub(/\e\[[0-9;]*[mGKHF]/, "")
    end

    spinner = Term::Spinner.new
    translated_text = ""

    spinner = Term::Spinner.new(clear: true)
    spinner.run do
      translated_text = translator.translate(option)
    end

    puts translated_text
  rescue ex
    STDERR.puts "ERROR: #{ex.class} #{ex.message}"
    exit(1)
  end
end
