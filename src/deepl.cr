require "option_parser"
require "./deepl/translator"
require "./deepl/version"

target_lang = "EN"
source_lang = ""

parser = OptionParser.new do |opts|
  opts.banner = "Usage: deepl [arguments]"
  opts.on("-f", "--from=LANG", "Source language [AUTO]") { |from| source_lang = from.upcase }
  opts.on("-t", "--to=LANG", "Target language [EN]") { |to| target_lang = to.upcase }
  opts.on("-v", "--version", "Show version") do
    puts Deepl::VERSION
    exit
  end
  opts.on("-h", "--help", "Show this help") do
    puts opts
    exit
  end
  opts.invalid_option do |flag|
    STDERR.puts "ERROR: #{flag} is not a valid option."
    STDERR.puts opts
    exit(1)
  end
end

parser.parse(ARGV)

input_text = ARGV.join(" ")

if input_text.empty?
  STDERR.puts parser
  exit(1)
end

begin
  translator = Deepl::Translator.new
rescue Deepl::ApiKeyError
  STDERR.puts "ERROR: Deepl API key not found. Please set the DEEPL_API_KEY environment variable."
  exit(1)
end

begin
  translated_text = translator.translate(input_text, target_lang, source_lang)
rescue ex
  STDERR.puts "ERROR: #{ex}"
  exit(1)
end


puts translated_text
