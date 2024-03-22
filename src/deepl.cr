require "option_parser"
require "term-spinner"

require "./deepl/translator"
require "./deepl/parser"
require "./deepl/version"

module DeepL
  def self.run
    parser = DeepL::Parser.new
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
      translator = DeepL::Translator.new
      translated_text = translator.translate(option)
    end

    puts translated_text
  rescue ex
    if DeepLError.debug
      STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}\n#{ex.backtrace.join("\n")}"
    else
      STDERR.puts "[deepl-cli] ERROR: #{ex.class} #{ex.message}"
    end
    exit(1)
  end

  def self.show_source_languages
    translator = DeepL::Translator.new
    translator.source_languages.each do |lang|
      language, name = lang.values.map(&.to_s)
      puts "- #{language.ljust(7)}#{name}"
    end
    exit
  end

  def self.show_target_languages
    translator = DeepL::Translator.new
    translator.target_languages.each do |lang|
      language, name, supports_formality = lang.values.map(&.to_s)
      formality = (supports_formality == "true") ? "YES" : "NO"
      puts "- #{language.ljust(7)}#{name.ljust(20)}\tformality support [#{formality}]"
    end
    exit
  end

  def self.show_usage
    translator = DeepL::Translator.new
    puts translator.api_url_base
    puts translator.usage.map { |k, v| "#{k}: #{v}" }.join("\n")
    exit
  end
end
