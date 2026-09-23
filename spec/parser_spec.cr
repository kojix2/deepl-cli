require "./spec_helper"

describe DeepL::Parser do
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
