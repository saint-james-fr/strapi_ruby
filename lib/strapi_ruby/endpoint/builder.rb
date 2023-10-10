module StrapiRuby
  module Endpoint
    class Builder
      def initialize(options = {})
        @resource = options[:resource]
        @id = options[:id]
        @query = Query.new(options).call
        @result = nil
      end

      def call
        build_endpoint
        append_query
        @result
      end

      private

      def build_endpoint
        @result = if builds_collection?
                    "#{base_uri}/#{@resource}/#{@id}"
                  else
                    "#{base_uri}/#{@resource}"
                  end
      end

      def append_query
        @result += @query if @query
      end

      def builds_collection?
        !@id.nil?
      end

      def base_uri
        StrapiRuby.config.strapi_server_uri
      end
    end
  end
end
