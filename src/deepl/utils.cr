module DeepL
  module Utils
    def self.open_texteditor(path)
      editor = ENV.fetch("EDITOR") do
        {% if flag?(:windows) %}
          "notepad"
        {% else %}
          # Some programmers prefer to replace tabs with spaces in their text editors,
          # but as a result, they may not be able to properly handle tab-separated files
          # like glossaries. I am no exception. So nano is the default text editor here.
          "nano"
        {% end %}
      end
      # Pass args separately to avoid shell injection (e.g., "code --wait" → ["code", "--wait"]).
      parts = editor.split
      Process.run(parts[0], args: parts[1..] + [path.to_s], input: STDIN, output: STDOUT, error: STDERR)
    end

    def self.edit_text(text)
      tmp_file = File.tempfile(&.puts(text))
      open_texteditor(tmp_file.path)
      File.read(tmp_file.path)
    ensure
      tmp_file.try &.delete
    end
  end
end
