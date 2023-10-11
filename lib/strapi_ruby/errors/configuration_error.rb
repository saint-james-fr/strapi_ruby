module StrapiRuby
  class ConfigurationError < StandardError
    def initialize(message)
      super("#{ErrorMessage.configuration}\n #{message}")
    end
  end
end
