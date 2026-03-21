require "./spec_helper"

describe DeepL::Config do
  it "returns the target language" do
    original = ENV["DEEPL_TARGET_LANG"]?
    begin
      ENV["DEEPL_TARGET_LANG"] = "CRYSTAL"
      DeepL::Config.default_target_lang.should eq("CRYSTAL")
    ensure
      if original
        ENV["DEEPL_TARGET_LANG"] = original
      else
        ENV.delete("DEEPL_TARGET_LANG")
      end
    end
  end
end
