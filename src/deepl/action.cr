module DeepL
  enum Action : UInt8
    TranslateText
    # TranslateXML
    RephraseText
    TranslateDocument
    TranslateDocumentUpload
    TranslateDocumentStatus
    TranslateDocumentDownload
    CreateGlossary
    DeleteGlossaryByName
    DeleteGlossaryById
    EditGlossaryByName
    EditGlossaryById
    OutputGlossaryEntriesByName
    OutputGlossaryEntriesById
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
