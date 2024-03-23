module DeepL
  class DeepLError < Exception
    class_property debug : Bool = false
  end

  class ApiKeyError < DeepLError
    def initialize
      super("DEEPL_AUTH_KEY is not set.")
    end
  end

  class AuthorizationError < DeepLError
    def initialize
      super("Authorization failed, check your authentication key.")
    end
  end

  class QuotaExceededError < DeepLError
    def initialize
      super("Quota for this billing period has been exceeded.")
    end
  end

  class TooManyRequestsError < DeepLError
    def initialize
      super("The maximum number of failed attempts were reached.")
    end
  end

  # class ConnectionError < DeepLError
  #   def initialize(message)
  #     super("Connection to the DeepL API failed.")
  #   end
  # end

  class DocumentTranslationError < DeepLError
    def initialize
      super("Error occurred while translating document.")
    end
  end

  class GlossaryNotFoundError < DeepLError
    def initialize
      super("The specified glossary was not found.")
    end
  end

  class DocumentNotReadyError < DeepLError
    def initialize
      super("The translation of the specified document is not yet complete.")
    end
  end

  class RequestError < DeepLError
    def initialize(exception : Exception)
      super("#{exception.class} #{exception.message}")
    end

    def initialize(message : String)
      super(message)
    end
  end

  class UnknownSubCommandError < DeepLError
    def initialize
      super("Unknown sub command")
    end
  end
end
