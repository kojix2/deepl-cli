require "./spec_helper"

describe DeepL do
  it "has a version number" do
    DeepL::CLI::VERSION.should be_a(String)
  end

  it "prints document command help to stderr when the input file is missing" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "src/cli.cr", "--", "doc"],
      output: stdout,
      error: stderr
    )

    status.success?.should be_false
    stdout.to_s.should eq("")
    stderr_output = stderr.to_s
    stderr_output.should contain("[deepl-cli] ERROR: Input file is not specified")
    stderr_output.should contain("Usage: deepl doc [options] <file>")
  end

  it "prints glossary command help to stderr when the subcommand is missing" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "src/cli.cr", "--", "glossary"],
      output: stdout,
      error: stderr
    )

    status.success?.should be_false
    stdout.to_s.should eq("")
    stderr_output = stderr.to_s
    stderr_output.should contain("[deepl-cli] ERROR: Subcommand is not specified")
    stderr_output.should contain("Usage: deepl glossary [options] <subcommand>")
  end

  it "prints explicit glossary help to stdout" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "src/cli.cr", "--", "glossary", "--help"],
      output: stdout,
      error: stderr
    )

    status.success?.should be_true
    stdout.to_s.should contain("Usage: deepl glossary [options] <subcommand>")
    # FIXME: This is workaround for suppressing the ld: warning
    # Remove this when the underlying issue is resolved.
    # Currently, this warning is emitted only on macOS x86_64.
    filtered_stderr = stderr.to_s.lines.reject do |line|
      line.starts_with?("ld: warning:")
    end.join
    filtered_stderr.should eq("")
  end
end
