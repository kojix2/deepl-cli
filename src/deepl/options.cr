module Deepl
  enum SubCmd : UInt8
    Text
    Document
  end

  struct Options
    property target_lang : String = "EN"
    property source_lang : String = "AUTO"
    property glossary_id : String? = nil
    property input : String = ""
    property sub_command : SubCmd = SubCmd::Text
  end
end
