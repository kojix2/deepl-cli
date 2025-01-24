module DeepL
  class Config
    def self.target_lang : String
      tl = ENV["DEEPL_TARGET_LANG"]?
      return tl if tl
      # The language of the current locale
      # If the locale is de_DE.UTF-8, then the target language is DE
      {% if flag?(:darwin) || flag?(:unix) %}
        ENV["LANG"]?.try &.split("_").try &.first.upcase || "EN"
      {% elsif flag?(:windows) %}
        l = `powershell -Command "[System.Globalization.CultureInfo]::CurrentCulture.TwoLetterISOLanguageName"`
        l.empty? ? "EN" : l.strip.upcase
      {% else %}
        "EN"
      {% end %}
    end
  end
end
