module DeepL
  class Config
    DEFAULT_TARGET_LANG = "EN"

    def self.default_target_lang : String
      # Check environment variable first (highest priority)
      env_lang = ENV["DEEPL_TARGET_LANG"]?
      return env_lang if env_lang

      locale_lang = detect_locale_environment_language
      return locale_lang if locale_lang

      # Detect system language from locale
      system_lang = detect_system_language
      system_lang || DEFAULT_TARGET_LANG
    end

    def self.cache_dir : Path
      if dir = ENV["DEEPL_CLI_CACHE_DIR"]?
        return Path[dir] unless dir.blank?
      end

      {% if flag?(:windows) %}
        if localappdata = ENV["LOCALAPPDATA"]?
          return Path[localappdata, "deepl-cli", "Cache"]
        end
        Path.home.join("AppData", "Local", "deepl-cli", "Cache")
      {% elsif flag?(:darwin) %}
        Path.home.join("Library", "Caches", "deepl-cli")
      {% else %}
        if xdg_cache_home = ENV["XDG_CACHE_HOME"]?
          return Path[xdg_cache_home, "deepl-cli"] unless xdg_cache_home.blank?
        end
        Path.home.join(".cache", "deepl-cli")
      {% end %}
    end

    def self.cache_file : Path
      cache_dir.join("query_cache.json")
    end

    private def self.detect_system_language : String?
      {% if flag?(:darwin) || flag?(:unix) %}
        nil
      {% elsif flag?(:windows) %}
        detect_windows_language
      {% else %}
        nil
      {% end %}
    end

    private def self.detect_locale_environment_language : String?
      [ENV["LC_ALL"]?, ENV["LC_MESSAGES"]?, ENV["LANG"]?].each do |locale|
        if code = locale_to_language_code(locale)
          return code
        end
      end

      nil
    end

    private def self.locale_to_language_code(locale : String?) : String?
      return unless locale

      code = locale.split(/[_.@]/).first?.try(&.upcase)
      return if code.nil? || code == "C" || code == "POSIX" || code.starts_with?("C.")

      code
    end

    private def self.detect_windows_language : String?
      # Use PowerShell to get current culture language
      command_result = `powershell -Command "[System.Globalization.CultureInfo]::CurrentCulture.TwoLetterISOLanguageName"`
      return if command_result.empty?

      command_result.strip.upcase
    end
  end
end
