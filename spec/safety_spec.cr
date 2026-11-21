require "./spec_helper"
require "./support/scripted_server"
require "file_utils"

private class GlossaryPairResolver < DeepL::CLI
  def resolve(info : DeepL::MultilingualGlossaryInfo)
    resolve_or_select_language_pair(info)
  end
end

private class DownloadedDocumentTranslator < DeepL::Translator
  def translate_document_download(handle : DeepL::DocumentHandle, output_file)
    File.write(output_file, "received translation")
  end
end

private class FailingDocumentPublishCLI < DeepL::CLI
  def download(output_file : Path) : Path
    download_document_to_unique_file(
      DownloadedDocumentTranslator.new("test-key"),
      DeepL::DocumentHandle.new("id", "key"),
      output_file,
    )
  end

  private def link_document_output_file(temporary_path : Path, output_file : Path) : Path
    raise File::Error.new("simulated unsupported hard link", file: output_file)
  end
end

private def safety_glossary : DeepL::MultilingualGlossaryInfo
  DeepL::MultilingualGlossaryInfo.from_json(
    %({"glossary_id":"id","name":"test","creation_time":"2026-01-01T00:00:00Z","dictionaries":[{"source_lang":"DE","target_lang":"fr"},{"source_lang":"en","target_lang":"ja"},{"source_lang":"en","target_lang":"fr"}]}),
  )
end

describe "CLI safety" do
  it "preserves a received document and reports its location when publication fails" do
    dir = File.tempname("deepl-cli-recovery")
    Dir.mkdir(dir, 0o700)
    begin
      output = Path[dir] / "translated.txt"
      error = expect_raises(DeepL::DocumentDownloadError) do
        FailingDocumentPublishCLI.new.download(output)
      end
      File.read(error.recovery_path).should eq("received translation")
      error.message.to_s.should contain(error.recovery_path)
      File.exists?(output).should be_false
      Dir.children(dir).should eq([File.basename(error.recovery_path)])
    ensure
      FileUtils.rm_r(dir)
    end
  end

  it "uses an explicit source without the default target language" do
    cli = GlossaryPairResolver.new
    cli.option.source_lang = "DE"
    cli.option.target_lang = "EN"
    cli.resolve(safety_glossary).should eq({"de", "fr"})
  end

  it "filters both explicit languages against existing dictionaries" do
    cli = GlossaryPairResolver.new
    cli.option.source_lang = "EN"
    cli.option.target_lang = "JA"
    cli.option.target_lang_explicit = true
    cli.resolve(safety_glossary).should eq({"en", "ja"})
    cli.option.target_lang = "DE"
    expect_raises(ArgumentError, /No glossary dictionary/) { cli.resolve(safety_glossary) }
  end

  it "refuses an ambiguous filtered pair in a non-interactive session" do
    cli = GlossaryPairResolver.new
    cli.option.source_lang = "EN"
    expect_raises(Exception, "Selection cancelled") { cli.resolve(safety_glossary) }
  end

  it "requires --yes for non-interactive deletion by either name or ID" do
    responses = [
      ScriptedServer::Response.new(200, safety_glossary.to_json),
      ScriptedServer::Response.new(204),
    ]
    server = ScriptedServer.new(responses)
    env = {
      "DEEPL_AUTH_KEY"   => "test-key",
      "DEEPL_SERVER_URL" => server.url,
      "NO_PROXY"         => "127.0.0.1,localhost",
      "no_proxy"         => "127.0.0.1,localhost",
    }
    begin
      [["test"], ["--id", "id"]].each do |args|
        stderr = IO::Memory.new
        status = Process.run("crystal", ["run", "src/cli.cr", "--", "glossary", "delete"] + args,
          env: env, input: IO::Memory.new("yes\n"), output: IO::Memory.new, error: stderr)
        status.exit_code.should eq(1)
        stderr.to_s.should contain("requires --yes")
        server.requests.should be_empty
      end
      stderr = IO::Memory.new
      status = Process.run("crystal", ["run", "src/cli.cr", "--", "glossary", "delete", "--id", "--yes", "id"],
        env: env, input: IO::Memory.new, output: IO::Memory.new, error: stderr)
      status.success?.should be_true
      stderr.to_s.should contain("is deleted")
      server.requests.map(&.method).should eq(["GET", "DELETE"])
    ensure
      server.close
    end
  end
end
