module StrapiRuby
  module Interface
    # options could be strapi rest api parameter combined with :resource or just use :raw
    # :raw
    # :resource
    # :sort
    # :filters
    # :fields
    # :populate
    # :page
    # :page_size
    #
    def get(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      answer = @client.get(@endpoint)
      formatted_data = format_data(answer.data, options)

      OpenStruct.new(data: formatted_data, meta: answer.meta, errors: answer.errors)
    end

    def post(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      body = options[:data]
      answer = @client.post(@endpoint, body)

      OpenStruct.new(data: answer.data, meta: answer.meta, errors: answer.errors)
    end

    def put(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      body = options[:data]
      answer = @client.put(@endpoint, body)

      OpenStruct.new(data: answer.data, meta: answer.meta, errors: answer.errors)
    end

    def delete(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      answer = @client.delete(@endpoint)

      OpenStruct.new(data: answer.data, meta: answer.meta, errors: answer.errors)
    end

    private

    def validate_options(options)
      raise ConfigurationError, ErrorMessage.missing_configuration if @config.nil?
      raise ArgumentError, ErrorMessage.missing_resource unless options.key?(:resource)
      raise TypeError, "Invalid argument type. Expected String or Symbol, got #{options[:resource].class.name}" unless options[:resource].is_a?(String) || options[:resource].is_a?(Symbol)
      raise TypeError, "Invalid argument type. Expected Integer, got #{options[:id].class.name}" if options.key?(:id) && !options[:id].is_a?(Integer)
    end

    def build_endpoint(options)
      Endpoint::Builder.new(options).call
    end

    def format_data(data, options = {})
      Formatter.new(options).call(data)
    end
  end
end
