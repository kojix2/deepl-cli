require "./spec_helper"
require "./support/scripted_server"

private class UsagePrinter < DeepL::CLI
  def render_products(usage : DeepL::UsagePro) : String
    String.build do |output|
      print_usage_products(usage, output)
    end
  end
end

private class WriteLanguageNormalizer < DeepL::CLI
  def normalize(language : String?) : String?
    normalize_write_language(language)
  end
end

private class TranslationOptionValidator < DeepL::CLI
  def validate : Nil
    validate_translation_options
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

  it "forwards current text translation options" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        200,
        %({"translations":[{"detected_source_language":"EN","text":"Hallo"}]}),
        {"Content-Type" => "application/json"},
      ),
    ])
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        [
          "run", "src/cli.cr", "--", "text",
          "--input", "hello", "--from", "EN", "--to", "DE",
          "--glossary-ids", "glossary-1,glossary-2",
          "--style-id", "style-1",
          "--translation-memory-id", "memory-1",
          "--translation-memory-threshold", "75",
          "--tag-handling", "xml",
          "--tag-handling-version", "v2",
        ],
        env: cli_test_env(server),
        output: stdout,
        error: stderr
      )
    ensure
      server.close
    end

    status.success?.should be_true
    stdout.to_s.should eq("Hallo\n")
    stderr.to_s.should_not contain("ERROR")
    server.requests.map { |request| {request.method, request.resource} }.should eq([
      {"POST", "/v2/translate"},
    ])

    body = JSON.parse(server.requests.first.body)
    body["glossary_ids"].as_a.map(&.as_s).should eq(["glossary-1", "glossary-2"])
    body["style_id"].as_s.should eq("style-1")
    body["translation_memory_id"].as_s.should eq("memory-1")
    body["translation_memory_threshold"].as_i.should eq(75)
    body["tag_handling"].as_s.should eq("xml")
    body["tag_handling_version"].as_s.should eq("v2")
  end

  it "validates advanced translation options before sending a request" do
    validator = TranslationOptionValidator.new
    validator.option.glossary_ids = ["glossary-1"]
    expect_raises(ArgumentError, "--from is required with --glossary-ids.") do
      validator.validate
    end

    validator = TranslationOptionValidator.new
    validator.option.translation_memory_threshold = 101
    validator.option.translation_memory_id = "memory-1"
    expect_raises(ArgumentError, "--translation-memory-threshold must be between 0 and 100.") do
      validator.validate
    end

    validator = TranslationOptionValidator.new
    validator.option.translation_memory_threshold = 75
    expect_raises(ArgumentError, "--translation-memory-threshold requires --translation-memory-id.") do
      validator.validate
    end

    validator = TranslationOptionValidator.new
    validator.option.tag_handling_version = "v3"
    expect_raises(ArgumentError, "--tag-handling-version must be v1 or v2.") do
      validator.validate
    end

    validator = TranslationOptionValidator.new
    validator.option.tag_handling_version = "v2"
    expect_raises(ArgumentError, "--tag-handling-version requires --tag-handling.") do
      validator.validate
    end
  end

  it "normalizes CLI language codes for the Write API" do
    normalizer = WriteLanguageNormalizer.new

    normalizer.normalize("EN").should eq("en")
    normalizer.normalize("EN-GB").should eq("en-GB")
    normalizer.normalize("PT-BR").should eq("pt-BR")
    normalizer.normalize("ZH-HANS").should eq("zh-Hans")
    normalizer.normalize(nil).should be_nil
  end

  it "normalizes glossary language codes for the multilingual glossary API" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        201,
        %({"glossary_id":"glossary-1","name":"Test Glossary","dictionaries":[{"source_lang":"en","target_lang":"de"}],"creation_time":"2026-09-23T00:00:00Z"}),
        {"Content-Type" => "application/json"},
      ),
    ])
    input = File.tempfile("deepl-cli-glossary", ".tsv")
    input.puts "source\ttarget"
    input.close
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "glossary", "create", "-n", "Test Glossary", "-f", "EN", "-t", "DE", input.path],
        env: cli_test_env(server),
        output: stdout,
        error: stderr,
      )
    ensure
      server.close
      File.delete?(input.path)
    end

    status.success?.should be_true
    server.requests.map { |request| {request.method, request.resource} }.should eq([{"POST", "/v3/glossaries"}])
    dictionary = JSON.parse(server.requests.first.body)["dictionaries"].as_a.first
    dictionary["source_lang"].as_s.should eq("en")
    dictionary["target_lang"].as_s.should eq("de")
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
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        200,
        %({"improvements":[{"detected_source_language":"EN","text":"proton beam","target_language":"EN"}]}),
        {"Content-Type" => "application/json"},
      ),
    ])
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "correct", "--input", "helo", "--from", "EN"],
        env: cli_test_env(server),
        output: stdout,
        error: stderr
      )
    ensure
      server.close
    end

    status.success?.should be_true
    stdout.to_s.should eq("proton beam\n")
    stderr.to_s.should_not contain("ERROR")
    server.requests.map { |request| {request.method, request.resource} }.should eq([
      {"POST", "/v2/write/correct"},
    ])
    server.requests.first.body.should contain(%("text":["helo"]))
    server.requests.first.body.should contain(%("target_lang":"en"))
  end

  it "corrects standard input to standard output" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        200,
        %({"improvements":[{"detected_source_language":"EN","text":"proton beam","target_language":"EN"}]}),
        {"Content-Type" => "application/json"},
      ),
    ])
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "correct", "--from", "EN"],
        env: cli_test_env(server),
        input: IO::Memory.new("helo\n"),
        output: stdout,
        error: stderr
      )
    ensure
      server.close
    end

    status.success?.should be_true
    stdout.to_s.should eq("proton beam\n")
    stderr.to_s.should_not contain("ERROR")
    server.requests.map(&.resource).should eq(["/v2/write/correct"])
    server.requests.first.body.should contain(%q("text":["helo\n"]))
    server.requests.first.body.should contain(%("target_lang":"en"))
  end

  it "stores an uploaded document handle with owner-only permissions without printing its key" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        200,
        %({"document_id":"mock-document-id","document_key":"mock-document-key"}),
        {"Content-Type" => "application/json"},
      ),
    ])
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
        [
          "run", "src/cli.cr", "--", "doc",
          "--upload-only", "--handle", handle_path.to_s,
          "--from", "EN",
          "--glossary-ids", "glossary-1,glossary-2",
          "--style-id", "style-1",
          "--translation-memory-id", "memory-1",
          "--translation-memory-threshold", "75",
          input_path.to_s,
        ],
        env: cli_test_env(server),
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
      server.requests.map { |request| {request.method, request.resource} }.should eq([
        {"POST", "/v2/document"},
      ])
      request_body = server.requests.first.body
      request_body.should contain("glossary_ids")
      request_body.should contain("glossary-1,glossary-2")
      request_body.should contain("style_id")
      request_body.should contain("style-1")
      request_body.should contain("translation_memory_id")
      request_body.should contain("memory-1")
      request_body.should contain("translation_memory_threshold")
      request_body.should contain("75")
    ensure
      server.close
      File.delete?(input_path)
      File.delete?(handle_path)
    end
  end
end

private def cli_test_env(server : ScriptedServer) : Process::Env
  {
    "DEEPL_AUTH_KEY"   => "cli-test-key",
    "DEEPL_SERVER_URL" => server.url,
    "NO_PROXY"         => "127.0.0.1,localhost",
    "no_proxy"         => "127.0.0.1,localhost",
  }
end
