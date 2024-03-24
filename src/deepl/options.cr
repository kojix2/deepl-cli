module DeepL
  enum Action : UInt8
    Text
    Document
    FromLang
    ToLang
    Usage
    Version
    Help
  end

  struct Options
    property action : Action = Action::Text
    property input_text : String = ""
    property input_path : Path = Path.new
    property target_lang : String = "EN"
    property source_lang : String? = nil
    property formality : String? = nil
    property glossary_id : String? = nil
    property context : String? = nil
    property split_sentences : String? = nil
    property no_ansi : Bool = true
  end
end
