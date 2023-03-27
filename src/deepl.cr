require "./deepl/translator"

input_text = ARGV[0]
target_lang = "EN"

translator = Deepl::Translator.new
translated_text = translator.translate(input_text, target_lang)

puts translated_text
