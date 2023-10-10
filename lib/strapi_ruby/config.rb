module StrapiRuby
  class Config
    include StrapiRuby::Validations

    attr_accessor :strapi_server_uri,
                  :strapi_token,
                  :faraday,
                  :convert_to_html,
                  :convert_to_datetime,
                  :show_endpoint

    def initialize
      @strapi_server_uri = nil
      @strapi_token = nil
      @faraday = nil
      @convert_to_datetime = true
      @convert_to_html = []
      @show_endpoint = false
    end

    def call
      validate_config(self)
      # We convert to symbols if user passed strings for convert_to_html options
      @convert_to_html.map!(&:to_sym)
    end
  end
end
