module StrapiRuby
  class ClientError < StandardError
  end

  class ConnectionError < ClientError
    def initialize(message)
      super("There is a problem while initializing the connection with Faraday: #{message}")
    end
  end

  class UnauthorizedError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}. Make sure your strapi_token is valid.")
    end
  end

  class ForbiddenError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}. Make sure your strapi_token has the correct permissions or allow public access.")
    end
  end

  class NotFoundError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}.")
    end
  end

  class UnprocessableEntityError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}.")
    end
  end

  class ServerError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}. Please try again later.")
    end
  end

  class BadRequestError < ClientError
    def initialize(message, status)
      super("There is an error from the Strapi server with status #{status}: #{message}. Check parameters")
    end
  end

  class JSONParsingError < ClientError; end
end
