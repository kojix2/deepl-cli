require "../src/deepl/translator"

cmd = <<-CMD
powershell.exe -command
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.initialDirectory = $InitialDirectory
    $openFileDialog.filter = "All files (*.*)| *.*"
    $openFileDialog.ShowDialog() > $null
    Write-Host $openFileDialog.Filename
CMD

ps = Process.new(cmd, shell: true, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
stdout = ps.output
content = ps.output.gets_to_end
path = Path.windows(content.strip)
p File.exists?(path)

translator = DeepL::Translator.new
translator.translate_document(
  path: path,
  target_lang: "JA",
  source_lang: "EN",
)
