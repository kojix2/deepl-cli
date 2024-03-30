require "json"
require "../src/deepl/translator"

def config_path
  File.expand_path("config.json", Dir.current)
end

def setup_deepl_api_key
  if File.exists?(config_path)
    config = JSON.parse(File.read(config_path))
    if config["deepl_api_key"]?
      ENV["DEEPL_AUTH_KEY"] = config["deepl_api_key"].to_s
      return
    end
  end
  return if ENV["DEEPL_AUTH_KEY"]?

  api_key = prompt_for_api_key
  unless api_key.empty?
    save_api_key_to_config(api_key)
    show_message(
      message: "API Key saved successfully.\nPlease restart the application.",
      title: "API Key Saved"
    )
  else
    show_message("No API Key provided.", "NO API KEY")
  end
  exit
end

def prompt_for_api_key
  input_dialog_cmd = <<-CMD
  powershell -Command
      Add-Type -AssemblyName Microsoft.VisualBasic
      Add-Type -AssemblyName System.Windows.Forms
      $apiKey = [Microsoft.VisualBasic.Interaction]::InputBox(\\"Enter your DeepL API Key:\\", \\"API Key\\", \\"\\")
      Write-Host $apiKey
  CMD

  ps = Process.new(input_dialog_cmd, shell: true, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
  api_key = ps.output.gets_to_end.strip
  ps.wait
  api_key
end

def save_api_key_to_config(api_key : String)
  config = {"deepl_api_key" => api_key}
  File.write("config.json", config.to_json)
end

def select_file
  file_types = {
    "All Files"                => "*.*",
    "Word Documents"           => "*.docx",
    "PowerPoint Presentations" => "*.pptx",
    "Excel Workbooks"          => "*.xlsx",
    "PDF Files"                => "*.pdf",
    "HTML Documents"           => "*.htm;*.html",
    "Text Files"               => "*.txt",
    "XLIFF Documents"          => "*.xlf;*.xliff",
  }

  filter_string = file_types.map { |d, e| "#{d} (#{e})|#{e}" }.join("|")

  cmd = <<-CMD
  powershell -Command
    Add-Type -AssemblyName System.Windows.Forms
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.filter = \\"#{filter_string}\\"
    $openFileDialog.ShowDialog() > $null
    Write-Host $openFileDialog.Filename
  CMD

  ps = Process.new(cmd, shell: true, output: Process::Redirect::Pipe, error: Process::Redirect::Pipe)
  content = ps.output.gets_to_end
  Path.windows(content.strip)
end

def main
  setup_deepl_api_key

  path = ARGV.size > 0 && File.exists?(ARGV[0]) ? Path.windows(ARGV[0]) : select_file
  exit(0) if path == Path[""]

  translator = DeepL::Translator.new
  translator.translate_document(
    path: path, target_lang: DeepL::Config.target_lang
  )
  show_message("Translation completed successfully\n#{translator.usage}", "Success")
rescue ex
  error_message = "ERROR: #{ex.class} #{ex.message}"
  error_message += "\n#{ex.response}" if ex.is_a?(Crest::RequestFailed)

  show_message(error_message, "Error")
  if ex.is_a?(Crest::Forbidden)
    if File.exists?(config_path)
      File.delete(config_path)
      show_message(
        message: "The API Key stored in the configuration file has been deleted due to authorization failure. \n" \
                 "Please restart the application and enter a valid API Key.",
        title: "API Key Error",
        icon: "Warning"
      )
    else
      show_message(
        message: "The Environment Variable DEEPL_AUTH_KEY is set but appears to be invalid. \n" \
                 "Please verify and correct the Environment Variable DEEPL_AUTH_KEY.",
        title: "API Key Error",
        icon: "Warning"
      )
    end
  end

  exit(1)
end

def show_message(message : String, title : String, icon : String = "Information")
  cmd = <<-CMD
  powershell -Command
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show(
      \\"#{message}\\", \\"#{title}\\",
      [System.Windows.Forms.MessageBoxButtons]::OK,
      [System.Windows.Forms.MessageBoxIcon]::#{icon}
    )
  CMD
  Process.run(cmd, shell: true)
end

main()
