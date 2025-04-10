module StrapiRuby
  module Endpoint
    class Builder
      def initialize(options = {})
        @resource = options[:resource]
        @document_id = options[:document_id]
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
        @result = if collection?
                    "#{base_uri}/#{@resource}"
                  else
                    "#{base_uri}/#{@resource}/#{@document_id}"
                  end
      end

      def append_query
        @result += @query if @query
      end

      def collection?
        @document_id.nil?
      end

      def base_uri
        StrapiRuby.config.strapi_server_uri
      end
    end
  end
end
