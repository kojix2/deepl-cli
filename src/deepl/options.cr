module Deepl
  enum SubCmd : UInt8
    Text
    Document
  end

  struct Options
    property sub_command : SubCmd = SubCmd::Text
    property input : String = ""
    property target_lang : String = "EN"
    property source_lang : String? = nil
    property glossary_id : String? = nil
  end
end
