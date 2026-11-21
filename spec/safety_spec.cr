require "./spec_helper"
require "./support/scripted_server"
require "file_utils"

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
end
