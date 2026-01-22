require "./spec_helper"

private class TTYMemory < IO::Memory
  def tty? : Bool
    true
  end
end

describe Term::Prompt do
  it "auto-selects when only one item" do
    input = TTYMemory.new("2\n")
    output = TTYMemory.new
    prompt = Term::Prompt.new(input, output)

    selected = prompt.select("Select language pair", ["en -> ja"])

    selected.should eq("en -> ja")
    output.to_s.should_not contain("Select [1-1]")
  end

  it "selects default (1) on empty input" do
    input = TTYMemory.new("\n")
    output = TTYMemory.new
    prompt = Term::Prompt.new(input, output)

    selected = prompt.select("Select item", ["a", "b"])

    selected.should eq("a")
  end

  it "returns nil on q" do
    input = TTYMemory.new("q\n")
    output = TTYMemory.new
    prompt = Term::Prompt.new(input, output)

    selected = prompt.select("Select item", ["a", "b"])

    selected.should be_nil
  end

  it "re-prompts on invalid input" do
    input = TTYMemory.new("3\n2\n")
    output = TTYMemory.new
    prompt = Term::Prompt.new(input, output)

    selected = prompt.select("Select item", ["a", "b"])

    selected.should eq("b")
    output.to_s.should contain("Invalid selection")
  end
end
