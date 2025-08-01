require "./spec_helper"

describe DeepL::Config do
  it "returns the target language" do
    ENV["DEEPL_TARGET_LANG"] = "CRYSTAL"
    DeepL::Config.default_target_lang.should eq("CRYSTAL")
  end
end
