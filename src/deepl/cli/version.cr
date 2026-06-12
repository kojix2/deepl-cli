module DeepL
  class CLI
    VERSION        = {{ `shards version #{__DIR__}`.chomp.stringify }}
    BASE_VERSION_STRING =
      if Translator::DEEPL_SERVER_URL != Translator::DEEPL_DEFAULT_SERVER_URL
        "deepl-cli #{VERSION} (#{Translator::DEEPL_SERVER_URL})"
      elsif Translator::DEEPL_SERVER_URL_FREE != Translator::DEEPL_DEFAULT_SERVER_URL_FREE
        "deepl-cli #{VERSION} (#{Translator::DEEPL_SERVER_URL_FREE})"
      else
        "deepl-cli #{VERSION}"
      end
    VERSION_STRING =
      {% if flag?(:no_clipboard) %}
        "#{BASE_VERSION_STRING} (clipboard disabled)"
      {% else %}
        BASE_VERSION_STRING
      {% end %}
  end
end
