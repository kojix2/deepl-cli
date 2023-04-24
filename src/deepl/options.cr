module Deepl
  struct Options
    property target_lang : String
    property source_lang : String
    property input_text : String

    def initialize
      @target_lang = "EN"
      @source_lang = "AUTO"
      @input_text = ""
    end
  end
end
