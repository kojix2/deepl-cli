require "./config"

module DeepL
  enum Action : UInt8
    TranslateText
    TranslateDocument
    ListGlossaryLanguagePairs
    CreateGlossary
    DeleteGlossary
    OutputGlossaryEntries
    ListGlossaries
    ListFromLanguages
    ListTargetLanguages
    RetrieveUsage
    Version
    Help
    None
  end

  struct Options
    property action : Action = Action::TranslateText
    property input_text : String = ""
    property input_path : Path = Path.new
    property output_path : Path? = nil
    property target_lang : String = Config.target_lang
    property source_lang : String? = nil
    property formality : String? = nil
    property glossary_id : String? = nil
    property glossary_name : String? = nil
    property context : String? = nil
    property split_sentences : String? = nil
    property output_format : String? = nil
    property no_ansi : Bool = true
  end
end
