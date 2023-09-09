module Deepl
  struct Options
    property target_lang : String
    property source_lang : String
    property input : String

    def initialize
      @target_lang = "EN"
      @source_lang = "AUTO"
      @input = ""
    end
  end
end
