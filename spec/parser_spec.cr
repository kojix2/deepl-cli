require "./spec_helper"

describe DeepL::Parser do
  it "shows file arguments in the text command help" do
    parser = DeepL::Parser.new
    option = parser.parse(["text", "--help"])

    option.action.should eq(DeepL::Action::Help)
    parser.help_message.should contain("Usage: deepl text [options] [file ...]")
  end

  it "raises parse errors with the active subcommand help" do
    ex = expect_raises(DeepL::Parser::ParseError, "Invalid --interval value: \"abc\".") do
      DeepL::Parser.new.parse(["doc", "--interval", "abc"])
    end

    help_message = ex.help_message || raise "Expected subcommand help"
    help_message.should contain("Usage: deepl doc [options] <file>")
  end

  it "parses the correct command options" do
    option = DeepL::Parser.new.parse(["correct", "--input", "helo", "--from", "EN"])

    option.action.should eq(DeepL::Action::CorrectText)
    option.input_text.should eq("helo")
    option.source_lang.should eq("EN")
  end

  it "accepts an explicit glossary ID for text translation" do
    option = DeepL::Parser.new.parse(["text", "--glossary-id", "glossary-123"])

    option.action.should eq(DeepL::Action::TranslateText)
    option.glossary_id.should eq("glossary-123")
  end

  it "accepts an explicit glossary ID for document translation" do
    option = DeepL::Parser.new.parse(["doc", "--glossary-id", "glossary-123"])

    option.action.should eq(DeepL::Action::TranslateDocument)
    option.glossary_id.should eq("glossary-123")
  end

  it "keeps explicit document languages for translation and upload" do
    [
      {["doc", "-f", "en", "-t", "de", "file.pdf"], DeepL::Action::TranslateDocument},
      {["doc", "--upload-only", "-f", "en", "-t", "de", "file.pdf"], DeepL::Action::TranslateDocumentUpload},
      {["doc", "-f", "en", "-t", "de", "--upload-only", "file.pdf"], DeepL::Action::TranslateDocumentUpload},
    ].each do |args, action|
      option = DeepL::Parser.new.parse(args)

      option.action.should eq(action)
      option.source_lang.should eq("EN")
      option.target_lang.should eq("DE")
      args.should eq(["file.pdf"])
    end
  end

  it "selects language lists for text translation and Write commands" do
    [
      {["-f"], DeepL::Action::ListFromLanguages},
      {["text", "-f"], DeepL::Action::ListFromLanguages},
      {["rephrase", "-f"], DeepL::Action::ListWriteTargetLanguages},
      {["correct", "-f"], DeepL::Action::ListWriteTargetLanguages},
    ].each do |args, action|
      DeepL::Parser.new.parse(args).action.should eq(action)
    end
  end

  it "keeps an explicit rephrase language" do
    option = DeepL::Parser.new.parse(["rephrase", "--input", "helo", "--from", "en-US"])

    option.action.should eq(DeepL::Action::RephraseText)
    option.source_lang.should eq("EN-US")
  end

  it "tracks whether a glossary view target language was explicitly provided" do
    DeepL::Parser.new.parse(["glossary", "view", "MyGlossary"]).target_lang_explicit?.should be_false

    option = DeepL::Parser.new.parse(["glossary", "view", "MyGlossary", "--to", "JA"])
    option.target_lang.should eq("JA")
    option.target_lang_explicit?.should be_true
  end

  it "parses current text translation options" do
    option = DeepL::Parser.new.parse([
      "text",
      "--from", "EN",
      "--glossary-id", "glossary-1",
      "--glossary-id", "glossary-2",
      "--tag-handling", "xml",
    ])

    option.action.should eq(DeepL::Action::TranslateText)
    option.glossary_ids.should eq(["glossary-1", "glossary-2"])
    option.tag_handling.should eq("xml")
  end

  it "preserves manual XML splitting while allowing explicit outline detection" do
    DeepL::Parser.new.parse(["text", "--tag-handling", "xml"]).outline_detection?.should be_nil
    DeepL::Parser.new.parse(["text", "--splitting-tags", "par,title"]).outline_detection?.should be_false
    DeepL::Parser.new.parse(["text", "--no-outline-detection"]).outline_detection?.should be_false

    [
      ["text", "--outline-detection", "--splitting-tags", "par"],
      ["text", "--splitting-tags", "par", "--outline-detection"],
    ].each do |args|
      DeepL::Parser.new.parse(args).outline_detection?.should be_true
    end
  end

  it "parses current document translation options" do
    option = DeepL::Parser.new.parse([
      "doc",
      "--from", "EN",
      "--glossary-id", "glossary-1,glossary-2",
      "--watermark",
    ])

    option.action.should eq(DeepL::Action::TranslateDocument)
    option.glossary_ids.should eq(["glossary-1", "glossary-2"])
    option.enable_watermark.should be_true
  end
end
