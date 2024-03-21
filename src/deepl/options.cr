module DeepL
  enum SubCmd : UInt8
    Text
    Document
  end

  struct Options
    property sub_command : SubCmd = SubCmd::Text
    property input : String = ""
    property target_lang : String = "EN"
    property source_lang : String? = nil
    property formality : String? = nil
    property glossary_id : String? = nil
    property no_ansi : Bool = true
  end
end
