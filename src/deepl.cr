require "option_parser"
require "./deepl/translator"
require "./deepl/version"

target_lang = "EN"
source_lang = "AUTO"

begin
  translator = Deepl::Translator.new
rescue Deepl::ApiKeyError
  STDERR.puts "ERROR: Deepl API key not found. Please set the DEEPL_API_KEY environment variable."
  exit(1)
end

parser = OptionParser.new do |opts|
  opts.banner = "Usage: deepl [arguments]"
  opts.on("-f", "--from [LANG]", "Source language [AUTO]") do |from|
    if from.empty?
      translator.source_languages.each do |lang|
        puts lang.values.map { |i| i.to_s }.join("\t")
      end
      exit
    end
    source_lang = from.upcase
  end
  opts.on("-t", "--to [LANG]", "Target language [EN]") do |to|
    if to.empty?
      translator.target_languages.each do |lang|
        puts lang.values.map { |i| i.to_s }.join("\t")
      end
      exit
    end
    target_lang = to.upcase
  end
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
  translated_text = translator.translate(input_text, target_lang, source_lang)
rescue ex
  STDERR.puts "ERROR: #{ex}"
  exit(1)
end

puts translated_text
