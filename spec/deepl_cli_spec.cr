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
          "--glossary-id", "glossary-1",
          "--glossary-id", "glossary-2",
          "--style-id", "style-1",
          "--translation-memory-id", "memory-1",
          "--translation-memory-threshold", "75",
          "--tag-handling", "xml",
          "--tag-handling-version", "v2",
          "--reporting-tag", "batch-42",
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
    server.requests.first.headers["X-DeepL-Reporting-Tag"].should eq("batch-42")
  end

  it "validates advanced translation options before sending a request" do
    validator = TranslationOptionValidator.new
    validator.option.glossary_ids = ["glossary-1"]
    expect_raises(ArgumentError, "--from is required with --glossary-id.") do
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

  it "uses v3 language discovery for source and target lists" do
    languages = <<-JSON
      [
        {"lang":"en","name":"English","usable_as_source":true,"usable_as_target":false,"status":"stable","features":{}},
        {"lang":"de","name":"German","usable_as_source":true,"usable_as_target":true,"status":"stable","features":{"formality":{"status":"stable"}}}
      ]
      JSON
    server = ScriptedServer.new([
      ScriptedServer::Response.new(200, languages, {"Content-Type" => "application/json"}),
      ScriptedServer::Response.new(200, languages, {"Content-Type" => "application/json"}),
    ])

    begin
      source_output = IO::Memory.new
      source_status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "--from"],
        env: cli_test_env(server),
        output: source_output,
        error: IO::Memory.new,
      )
      target_output = IO::Memory.new
      target_status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "--to"],
        env: cli_test_env(server),
        output: target_output,
        error: IO::Memory.new,
      )
    ensure
      server.close
    end

    source_status.success?.should be_true
    target_status.success?.should be_true
    source_output.to_s.should contain("EN     English")
    source_output.to_s.should contain("DE     German")
    target_output.to_s.should_not contain("English")
    target_output.to_s.should contain("supports formality")
    server.requests.map(&.resource).should eq([
      "/v3/languages?resource=translate_text",
      "/v3/languages?resource=translate_text",
    ])
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
          "--glossary-id", "glossary-1,glossary-2",
          "--style-id", "style-1",
          "--translation-memory-id", "memory-1",
          "--translation-memory-threshold", "75",
          "--watermark",
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
      request_body.should contain("enable_watermark")
      request_body.should contain("true")
    ensure
      server.close
      File.delete?(input_path)
      File.delete?(handle_path)
    end
  end

  it "imports a Translation Memory and prints the completed job" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        201,
        %({"job_id":"job-import","upload_url":"{{SERVER_URL}}/signed-upload","expires_at":"2026-09-23T01:00:00Z"}),
        {"Content-Type" => "application/json"},
      ),
      ScriptedServer::Response.new(204),
      ScriptedServer::Response.new(
        200,
        translation_memory_job_json("job-import", "import", translation_memory_id: "memory-new"),
        {"Content-Type" => "application/json"},
      ),
    ])
    input = File.tempfile("deepl-cli-memory", ".tmx")
    input.print("<tmx>test</tmx>")
    input.close
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "memory", "import", "--name", "Legal", input.path],
        env: cli_test_env(server),
        output: stdout,
        error: stderr,
      )
    ensure
      server.close
      File.delete?(input.path)
    end

    status.success?.should be_true
    JSON.parse(stdout.to_s)["job_id"].as_s.should eq("job-import")
    stderr.to_s.should_not contain("ERROR")
    server.requests.map { |request| {request.method, request.resource} }.should eq([
      {"POST", "/v3/translation_memories/import"},
      {"PUT", "/signed-upload"},
      {"GET", "/v3/translation_memories/jobs/job-import"},
    ])
    import_body = JSON.parse(server.requests[0].body)
    import_body["source_file"]["file_name"].as_s.should eq(Path[input.path].basename.to_s)
    import_body["parameters"]["display_name"].as_s.should eq("Legal")
    server.requests[1].body.should eq("<tmx>test</tmx>")
    server.requests[1].headers.has_key?("Authorization").should be_false
  end

  it "exports a Translation Memory through its signed download URL" do
    server = ScriptedServer.new([
      ScriptedServer::Response.new(
        201,
        %({"job_id":"job-export","parameters":{"translation_memory_id":"memory-1"}}),
        {"Content-Type" => "application/json"},
      ),
      ScriptedServer::Response.new(
        200,
        translation_memory_job_json("job-export", "export", download_url: "{{SERVER_URL}}/signed-download"),
        {"Content-Type" => "application/json"},
      ),
      ScriptedServer::Response.new(200, "<tmx>exported</tmx>"),
    ])
    output = File.tempfile("deepl-cli-memory-export", ".tmx")
    output_path = output.path
    output.close
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "memory", "export", "--output", output_path, "memory-1"],
        env: cli_test_env(server),
        output: stdout,
        error: stderr,
      )

      status.success?.should be_true
      File.read(output_path).should eq("<tmx>exported</tmx>")
    ensure
      server.close
      File.delete?(output_path)
    end

    JSON.parse(stdout.to_s)["job_id"].as_s.should eq("job-export")
    stderr.to_s.should contain("Translation Memory exported")
    server.requests.map { |request| {request.method, request.resource} }.should eq([
      {"POST", "/v3/translation_memories/memory-1/export"},
      {"GET", "/v3/translation_memories/jobs/job-export"},
      {"GET", "/signed-download"},
    ])
    server.requests[2].headers.has_key?("Authorization").should be_false
  end

  it "shows Translation Memory jobs and force-deletes memories" do
    job_server = ScriptedServer.new([
      ScriptedServer::Response.new(
        200,
        translation_memory_job_json("job-1", "import", translation_memory_id: "memory-1"),
        {"Content-Type" => "application/json"},
      ),
    ])
    stdout = IO::Memory.new
    stderr = IO::Memory.new

    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "memory", "job", "job-1"],
        env: cli_test_env(job_server),
        output: stdout,
        error: stderr,
      )
    ensure
      job_server.close
    end

    status.success?.should be_true
    JSON.parse(stdout.to_s)["job_id"].as_s.should eq("job-1")

    delete_server = ScriptedServer.new([ScriptedServer::Response.new(204)])
    stdout = IO::Memory.new
    stderr = IO::Memory.new
    begin
      status = Process.run(
        "crystal",
        ["run", "src/cli.cr", "--", "memory", "delete", "--force", "memory-1"],
        env: cli_test_env(delete_server),
        output: stdout,
        error: stderr,
      )
    ensure
      delete_server.close
    end

    status.success?.should be_true
    delete_server.requests.map { |request| {request.method, request.resource} }.should eq([
      {"DELETE", "/v3/translation_memories/memory-1"},
    ])
    stderr.to_s.should contain("Translation Memory memory-1 is deleted")
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

private def translation_memory_job_json(
  job_id : String,
  operation : String,
  translation_memory_id : String? = nil,
  download_url : String? = nil,
) : String
  JSON.build do |json|
    json.object do
      json.field "job_id", job_id
      json.field "product", "translation_memory"
      json.field "operation", operation
      json.field "creation_time", "2026-09-23T00:00:00Z"
      json.field "updated_time", "2026-09-23T00:00:01Z"
      json.field "parameters" do
        json.object do
          json.field "translation_memory_id", translation_memory_id if translation_memory_id
        end
      end
      json.field "results" do
        json.array do
          json.object do
            json.field "status", "completed"
            json.field "translation_memory_id", translation_memory_id if translation_memory_id
            json.field "download_url", download_url if download_url
          end
        end
      end
    end
  end
end
