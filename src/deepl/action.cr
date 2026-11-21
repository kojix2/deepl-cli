module DeepL
  enum Action : UInt8
    TranslateText
    RephraseText
    CorrectText
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
    ListDocumentFromLanguages
    ListDocumentTargetLanguages
    ListWriteTargetLanguages
    RetrieveUsage
    Version
    Help
  end
end
