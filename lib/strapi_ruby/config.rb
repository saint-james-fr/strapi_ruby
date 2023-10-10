module StrapiRuby
  class Config
    attr_accessor :strapi_server_uri, :strapi_token, :faraday, :convert_to_html, :convert_to_datetime

    def initialize
      @strapi_server_uri = nil
      @strapi_token = nil
      @faraday = nil
      @convert_to_datetime = true
      @convert_to_html = []
    end

    def validate!
      raise ConfigurationError, "strapi_server_uri is missing" if @strapi_server_uri.nil? || @strapi_server_uri.empty?
      raise ConfigurationError, "strapi_token is missing" if @strapi_token.nil? || @strapi_token.empty?
      raise ArgumentError, "Expected Proc. Got #{@faraday.class.name}" if !@faraday.nil? && !@faraday.is_a?(Proc)

      raise ArgumentError, "Invalid argument type. Expected Array. Got #{@convert_to_html.class.name}" unless @convert_to_html.is_a?(Array)

      # We convert to symbols if user passed strings
      @convert_to_html.map!(&:to_sym)
    end
  end
end
