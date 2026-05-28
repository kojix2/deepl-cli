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
