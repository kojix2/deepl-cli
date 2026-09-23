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

  it "corrects --input text using the library command" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "src/cli.cr", "--", "correct", "--input", "helo", "--from", "EN"],
      env: {"DEEPL_AUTH_KEY" => "mock"},
      output: stdout,
      error: stderr
    )

    status.success?.should be_true
    stdout.to_s.should eq("proton beam\n")
    stderr.to_s.should_not contain("ERROR")
  end

  it "corrects standard input to standard output" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "src/cli.cr", "--", "correct", "--from", "EN"],
      env: {"DEEPL_AUTH_KEY" => "mock"},
      input: IO::Memory.new("helo\n"),
      output: stdout,
      error: stderr
    )

    status.success?.should be_true
    stdout.to_s.should eq("proton beam\n")
    stderr.to_s.should_not contain("ERROR")
  end

  it "stores an uploaded document handle with owner-only permissions without printing its key" do
    input = File.tempfile("deepl-cli-spec", ".txt")
    input.print("hello")
    input.close
    input_path = Path[input.path]
    handle_path = Path["#{input.path}.handle"]

    begin
      stdout = IO::Memory.new
      stderr = IO::Memory.new
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "doc", "--upload-only", "--handle", handle_path.to_s, input_path.to_s],
        env: {"DEEPL_AUTH_KEY" => "mock"},
        output: stdout,
        error: stderr
      )

      status.success?.should be_true
      # Windows exposes writable files as 0666: only OwnerWrite is effective
      # there, so its filesystem cannot report POSIX's owner-only 0600 mode.
      {% if flag?(:windows) %}
        File.info(handle_path).permissions.should eq(File::Permissions.new(0o666))
      {% else %}
        File.info(handle_path).permissions.should eq(File::Permissions.new(0o600))
      {% end %}
      File.read(handle_path).should contain("mock-document-key")
      stderr.to_s.should_not contain("mock-document-key")
    ensure
      File.delete?(input_path)
      File.delete?(handle_path)
    end
  end
end
