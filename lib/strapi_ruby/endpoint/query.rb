module StrapiRuby
  module Endpoint
    class Query
      include StrapiParameters

      def initialize(options = {})
        @result = ""
        @options = options
        parse_query_params
      end

      def call
        if @options[:raw]
          @result = @options[:raw]
        else
          @result
        end
      end

      private

      def parse_query_params
        return if @options[:raw]

        @options.each do |key, value|
          send(key, value) if @options[key] && respond_to?(key, true)
        end
      end
    end
  end
end
