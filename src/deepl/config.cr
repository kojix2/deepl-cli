module DeepL
  class Config
    DEFAULT_TARGET_LANG = "EN"

    def self.default_target_lang : String
      # Check environment variable first (highest priority)
      env_lang = ENV["DEEPL_TARGET_LANG"]?
      return env_lang if env_lang

      # Detect system language from locale
      system_lang = detect_system_language
      system_lang || DEFAULT_TARGET_LANG
    end

    private def self.detect_system_language : String?
      {% if flag?(:darwin) || flag?(:unix) %}
        detect_unix_language
      {% elsif flag?(:windows) %}
        detect_windows_language
      {% else %}
        nil
      {% end %}
    end

    private def self.detect_unix_language : String?
      # Extract language code from LANG environment variable
      # Example: "de_DE.UTF-8" -> "DE"
      lang_env = ENV["LANG"]?
      return nil unless lang_env

      lang_parts = lang_env.split("_")
      lang_parts.first?.try(&.upcase)
    end

    private def self.detect_windows_language : String?
      # Use PowerShell to get current culture language
      command_result = `powershell -Command "[System.Globalization.CultureInfo]::CurrentCulture.TwoLetterISOLanguageName"`
      return nil if command_result.empty?

      command_result.strip.upcase
    end
  end
end
