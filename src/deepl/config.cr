module DeepL
  class Config
    DEFAULT_TARGET_LANG = "EN"

    def self.default_target_lang : String
      # Check environment variable first (highest priority)
      env_lang = ENV["DEEPL_TARGET_LANG"]?.presence
      return env_lang if env_lang

      locale_lang = detect_locale_environment_language
      return locale_lang if locale_lang

      # Detect system language from locale
      system_lang = detect_system_language
      system_lang || DEFAULT_TARGET_LANG
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

    # Accepts POSIX locales (en_GB.UTF-8, zh_TW@euro) and BCP 47 names (en-GB, zh-Hant-HK).
    private def self.locale_to_language_code(locale : String?) : String?
      return if locale.nil?

      parts = locale.strip.split(/[.@]/).first.split(/[-_]/).map(&.upcase)
      language = parts.shift?
      return if language.nil? || language.empty? || language == "C" || language == "POSIX"

      language_variant(language, parts) || language
    end

    private def self.language_variant(language : String, subtags : Array(String)) : String?
      case language
      when "EN"
        return "EN-GB" if subtags.includes?("GB")
        return "EN-US" if subtags.includes?("US")
      when "PT"
        return "PT-BR" if subtags.includes?("BR")
        return "PT-PT" if subtags.includes?("PT")
      when "ZH"
        return "ZH-HANT" if subtags.includes?("HANT")
        return "ZH-HANS" if subtags.includes?("HANS")
        return "ZH-HANT" if subtags.any? { |tag| {"TW", "HK", "MO"}.includes?(tag) }
        return "ZH-HANS" if subtags.any? { |tag| {"CN", "SG"}.includes?(tag) }
      end
      nil
    end

    private def self.detect_windows_language : String?
      # CultureInfo.Name keeps the region and script, e.g. en-GB or zh-Hant-TW.
      command_result = `powershell -Command "[System.Globalization.CultureInfo]::CurrentCulture.Name"`
      locale_to_language_code(command_result)
    end
  end
end
