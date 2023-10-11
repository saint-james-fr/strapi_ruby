module StrapiRuby
  class ClientError < StandardError
    def initialize(message)
      super(message)
      StrapiRuby.logger.error(message)
    end
  end

  class ConnectionError < ClientError
    def initialize(message)
      super("#{ErrorMessage.faraday_connection} #{message}")
    end
  end

  class UnauthorizedError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}. Make sure your strapi_token is valid.")
    end
  end

  class ForbiddenError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}. Make sure your strapi_token has the correct permissions or allow public access.")
    end
  end

  class NotFoundError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}.")
    end
  end

  class UnprocessableEntityError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}.")
    end
  end

  class ServerError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}. Please try again later.")
    end
  end

  class BadRequestError < ClientError
    def initialize(message, status)
      super("#{ErrorMessage.strapi_server_status} #{status}: #{message}. Check parameters")
    end
  end

  class JSONParsingError < ClientError; end
end
