require "./config"
require "./action"

module DeepL
  struct Options
    property action : Action = Action::TranslateText
    property help_error_message : String? = nil
    property input_text : String = ""
    property input_path : Path = Path.new
    property output_file : Path? = nil
    property target_lang : String = Config.default_target_lang
    property source_lang : String? = nil
    property? detect_source_language : Bool = false
    property? show_billed_characters : Bool = false
    property formality : String? = nil
    property glossary_id : String? = nil
    property glossary_ids : Array(String)? = nil
    property glossary_name : String? = nil
    property context : String? = nil
    property split_sentences : String? = nil
    property? preserve_formatting : Bool = false
    property tag_handling : String? = nil
    property tag_handling_version : String? = nil
    property? outline_detection : Bool = false
    property non_splitting_tags : Array(String)? = nil
    property splitting_tags : Array(String)? = nil
    property ignore_tags : Array(String)? = nil
    property output_format : String? = nil
    property? no_ansi : Bool = true
    property interval : Float32 = 5.0
    property poll_timeout : Time::Span? = nil
    property document_id : String? = nil
    property document_key : String? = nil
    property document_handle_file : Path? = nil
    property model_type : String? = nil
    property style_id : String? = nil
    property translation_memory_id : String? = nil
    property translation_memory_threshold : Int32? = nil
    property reporting_tag : String? = nil
    property enable_watermark : Bool? = nil
    property page : Int32? = nil
    property page_size : Int32? = nil
    property page_cursor : String? = nil
    property filter_text : String? = nil
    property? filter_case_sensitive : Bool? = nil
    property writing_style : String? = nil
    property tone : String? = nil
  end
end
