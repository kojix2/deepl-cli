module DeepL
  enum Action : UInt8
    TranslateText
    # TranslateXML
    TranslateDocument
    ListGlossaryLanguagePairs
    CreateGlossary
    DeleteGlossary
    EditGlossary
    OutputGlossaryEntries
    ListGlossaries
    ListGlossariesLong
    ListFromLanguages
    ListTargetLanguages
    RetrieveUsage
    Version
    Help
    None
  end
end
