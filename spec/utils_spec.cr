require "./spec_helper"

describe DeepL::Utils do
  describe ".texteditor_command_parts" do
    it "keeps quoted editor paths and arguments together" do
      with_editor(%q("/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --wait)) do
        DeepL::Utils.texteditor_command_parts.should eq([
          "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code",
          "--wait",
        ])
      end
    end

    it "preserves quoted empty arguments" do
      with_editor(%q(emacsclient -c -a "")) do
        DeepL::Utils.texteditor_command_parts.should eq(["emacsclient", "-c", "-a", ""])
      end
    end

    it "falls back to the default editor when EDITOR is empty" do
      with_editor("  ") do
        {% if flag?(:windows) %}
          DeepL::Utils.texteditor_command_parts.should eq(["notepad"])
        {% else %}
          DeepL::Utils.texteditor_command_parts.should eq(["nano"])
        {% end %}
      end
    end
  end

  describe ".edit_text" do
    it "rejects changes from a failed editor and removes the temporary file" do
      marker = File.tempfile("deepl-editor-spec", ".path")
      marker.close

      begin
        editor = Process.quote([
          "crystal", "eval",
          %q(File.write(ARGV[0], ARGV[1]); File.write(ARGV[1], "changed"); exit(7)),
          "--", marker.path,
        ])
        with_editor(editor) do
          expect_raises(Exception, "Text editor failed (status: 7).") do
            DeepL::Utils.edit_text("original")
          end
        end

        edited_path = File.read(marker.path)
        edited_path.should_not be_empty
        File.exists?(edited_path).should be_false
      ensure
        File.delete?(marker.path)
      end
    end

    it "reports editor failure even if the editor removes the temporary file" do
      editor = Process.quote(["crystal", "eval", "File.delete(ARGV[0]); exit(7)", "--"])
      with_editor(editor) do
        expect_raises(Exception, "Text editor failed (status: 7).") do
          DeepL::Utils.edit_text("original")
        end
      end
    end

    {% if flag?(:unix) %}
      it "reports an editor terminated by a signal" do
        editor = Process.quote(["sh", "-c", "kill -TERM $$", "--"])
        with_editor(editor) do
          expect_raises(Exception, "Text editor failed (status: TERM).") do
            DeepL::Utils.edit_text("original")
          end
        end
      end
    {% end %}
  end
end

private def with_editor(value, &)
  original = ENV["EDITOR"]?
  ENV["EDITOR"] = value
  yield
ensure
  if original
    ENV["EDITOR"] = original
  else
    ENV.delete("EDITOR")
  end
end
