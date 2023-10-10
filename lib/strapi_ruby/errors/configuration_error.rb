module StrapiRuby
  class ConfigurationError < StandardError
    def initialize(message)
      super("You must configure StrapiRuby before using it. See README.md for details.\n #{message}")
    end
  end
end
