require "./config"
require "./action"

module DeepL
  struct Options
    property action : Action = Action::TranslateText
    property input_text : String = ""
    property input_path : Path = Path.new
    property output_file : Path? = nil
    property target_lang : String = Config.target_lang
    property source_lang : String? = nil
    property detect_source_language : Bool = false
    property show_billed_characters : Bool = false
    property formality : String? = nil
    # property glossary_id : String? = nil
    property glossary_name : String? = nil
    property context : String? = nil
    property split_sentences : String? = nil
    property preserve_formatting : Bool = false
    property tag_handling : String? = nil
    property outline_detection : Bool = false
    property non_splitting_tags : Array(String)? = nil
    property splitting_tags : Array(String)? = nil
    property ignore_tags : Array(String)? = nil
    property output_format : String? = nil
    property no_ansi : Bool = true
    property interval : Float32 = 5.0
  end
end
