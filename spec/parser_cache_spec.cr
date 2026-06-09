require "./spec_helper"

describe DeepL::Parser do
  it "uses cache size default 10" do
    parser = DeepL::Parser.new
    option = parser.parse([] of String)

    option.cache_size.should eq(10)
  end

  it "parses cache options in text command" do
    parser = DeepL::Parser.new
    option = parser.parse(["text", "--no-cache", "--force-refresh", "--cache-size", "3"])

    option.cache_enabled?.should be_false
    option.force_refresh?.should be_true
    option.cache_size.should eq(3)
  end

  it "parses cache options in rephrase command" do
    parser = DeepL::Parser.new
    option = parser.parse(["rephrase", "--cache-size", "2"])

    option.cache_size.should eq(2)
  end
end
