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

    def validate!
      validate_config(self)


      
      raise TypeError, "Invalid argument type. Expected Array. Got #{@convert_to_html.class.name}" unless @convert_to_html.is_a?(Array)
      raise TypeError, "Invalid argument type. Expected Boolean" unless [true, false].include?(@show_endpoint)

      # We convert to symbols if user passed strings
      @convert_to_html.map!(&:to_sym)
    end
  end
end
