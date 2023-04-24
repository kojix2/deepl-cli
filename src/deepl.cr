require "option_parser"
require "term-spinner"

require "./deepl/translator"
require "./deepl/parser"
require "./deepl/version"

begin
  translator = Deepl::Translator.new
rescue Deepl::ApiKeyError
  STDERR.puts "ERROR: Deepl API key not found. Please set the DEEPL_API_KEY environment variable."
  exit(1)
end

parser = Deepl::Parser.new(translator)

option = parser.parse(ARGV)

if option.input_text.empty?
  begin
    option.input_text = ARGF.gets_to_end
  rescue ex
    STDERR.puts parser
    STDERR.puts "ERROR: #{ex}"
    exit(1)
  end
end

spinner = Term::Spinner.new
translated_text = ""

begin
  spinner = Term::Spinner.new(clear: true)
  spinner.run do
    translated_text = translator.translate(option)
  end
rescue ex
  STDERR.puts "ERROR: #{ex}"
  exit(1)
end

puts translated_text
