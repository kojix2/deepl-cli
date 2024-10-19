module DeepL
  enum Action : UInt8
    TranslateText
    # TranslateXML
    TranslateDocument
    TranslateDocumentUpload
    TranslateDocumentStatus
    TranslateDocumentDownload
    ListGlossaryLanguagePairs
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
