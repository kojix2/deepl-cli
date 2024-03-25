module DeepL
  class Config
    def self.auth_key : String
      ENV.fetch("DEEPL_AUTH_KEY") {
        # For backward compatibility
        ENV.fetch("DEEPL_API_KEY") { raise ApiKeyError.new }
      }
    end

    def self.user_agent : String
      ENV["DEEPL_USER_AGENT"]? || "deepl-cli/#{VERSION}"
    end
  end
end
