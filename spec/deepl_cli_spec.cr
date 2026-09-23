require "./spec_helper"

private class UsagePrinter < DeepL::CLI
  def render_products(usage : DeepL::UsagePro) : String
    String.build do |output|
      print_usage_products(usage, output)
    end
  end
end

describe DeepL do
  it "has a version number" do
    DeepL::CLI::VERSION.should be_a(String)
  end

  it "prints non-empty Pro products without deprecated character fields" do
    usage = DeepL::UsagePro.from_json(<<-JSON)
      {
        "character_count": 0,
        "character_limit": 1,
        "products": [
          {
            "product_type": "translate",
            "billing_unit": "characters",
            "api_key_unit_count": 42,
            "account_unit_count": 84,
            "character_count": 100,
            "api_key_character_count": 50
          },
          {
            "billing_unit": "minutes"
          }
        ]
      }
      JSON

    expected = <<-TEXT
      products:
        product 1:
          product_type: translate
          billing_unit: characters
          api_key_unit_count: 42
          account_unit_count: 84
        product 2:
          billing_unit: minutes
      TEXT
    UsagePrinter.new.render_products(usage).should eq(expected + "\n")
  end

  it "does not print empty Pro products" do
    usage = DeepL::UsagePro.from_json(%({"character_count":0,"character_limit":1}))

    UsagePrinter.new.render_products(usage).should eq("")
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
    {% if flag?(:darwin) %}
      # Crystal's macOS linker can emit a non-fatal warning.
      stderr.to_s.lines.reject { |line| line.starts_with?("ld: warning:") }.join.should eq("")
    {% else %}
      stderr.to_s.should eq("")
    {% end %}
  end

  it "corrects --input text using the library command" do
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    status = Process.run(
      "crystal",
      ["run", "-Ddeepl_mock", "src/cli.cr", "--", "correct", "--input", "helo", "--from", "EN"],
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
      ["run", "-Ddeepl_mock", "src/cli.cr", "--", "correct", "--from", "EN"],
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
        ["run", "-Ddeepl_mock", "src/cli.cr", "--", "doc", "--upload-only", "--handle", handle_path.to_s, input_path.to_s],
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
