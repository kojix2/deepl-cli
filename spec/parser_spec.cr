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
      "--style-id", "style-1",
      "--translation-memory-id", "memory-1",
      "--translation-memory-threshold", "75",
      "--tag-handling", "xml",
      "--tag-handling-version", "v2",
    ])

    option.action.should eq(DeepL::Action::TranslateText)
    option.glossary_ids.should eq(["glossary-1", "glossary-2"])
    option.style_id.should eq("style-1")
    option.translation_memory_id.should eq("memory-1")
    option.translation_memory_threshold.should eq(75)
    option.tag_handling.should eq("xml")
    option.tag_handling_version.should eq("v2")
  end

  it "parses current document translation options" do
    option = DeepL::Parser.new.parse([
      "doc",
      "--from", "EN",
      "--glossary-id", "glossary-1,glossary-2",
      "--style-id", "style-1",
      "--translation-memory-id", "memory-1",
      "--translation-memory-threshold", "80",
      "--poll-timeout", "30",
    ])

    option.action.should eq(DeepL::Action::TranslateDocument)
    option.glossary_ids.should eq(["glossary-1", "glossary-2"])
    option.style_id.should eq("style-1")
    option.translation_memory_id.should eq("memory-1")
    option.translation_memory_threshold.should eq(80)
    option.document_timeout.should eq(30.seconds)
  end

  it "parses translation memory subcommands" do
    list = DeepL::Parser.new.parse(["memory", "list", "--page", "2", "--page-size", "25"])
    list.action.should eq(DeepL::Action::ListTranslationMemories)
    list.page.should eq(2)
    list.page_size.should eq(25)

    args = ["memory", "segments", "--page-size", "10", "--cursor", "next", "--filter", "term", "--case-sensitive", "memory-1"]
    segments = DeepL::Parser.new.parse(args)
    segments.action.should eq(DeepL::Action::ListTranslationMemorySegments)
    segments.page_size.should eq(10)
    segments.page_cursor.should eq("next")
    segments.filter_text.should eq("term")
    segments.filter_case_sensitive?.should be_true
    args.should eq(["memory-1"])
  end
end
