module StrapiRuby
  module Configuration
    def config
      @config ||= Config.new
    end

    def configure
      yield(config)
      config.call
      client
    end

    private

    def client
      @client ||= Client.new(
        strapi_server_uri: @config.strapi_server_uri, strapi_token: @config.strapi_token, &@config.faraday
      )
    end
  end
end
