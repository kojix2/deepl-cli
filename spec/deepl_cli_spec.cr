require "./spec_helper"

describe DeepL do
  it "has a version number" do
    DeepL::CLI::VERSION.should be_a(String)
  end
end
