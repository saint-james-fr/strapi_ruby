module StrapiRuby
  module Interface
    def get(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      answer = @client.get(@endpoint)
      data = format_data(answer.data, options)
      meta = answer.meta

      build_open_struct(data, meta, options)
    end

    def post(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      body = options[:data]
      answer = @client.post(@endpoint, body)
      data = answer.data
      meta = answer.meta

      build_open_struct(data, meta, options)
    end

    def put(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      body = options[:data]
      answer = @client.put(@endpoint, body)
      data = answer.data
      meta = answer.meta

      build_open_struct(data, meta, options)
    end

    def delete(options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      answer = @client.delete(@endpoint)
      data = answer.data
      meta = answer.meta

      build_open_struct(data, meta, options)
    end

    private

    def build_open_struct(data, meta, options = {})
      # If user wants to see endpoint, we add it to the response
      if options[:show_endpoint] || StrapiRuby.config.show_endpoint
        OpenStruct.new(data: data, meta: meta, endpoint: @endpoint)
      else
        OpenStruct.new(data: data, meta: meta)
      end
    end

    def validate_options(options)
      raise ConfigurationError, ErrorMessage.missing_configuration if @config.nil?
      raise ArgumentError, ErrorMessage.missing_resource unless options.key?(:resource)
      raise TypeError, "Invalid argument type. Expected String or Symbol, got #{options[:resource].class.name}" unless options[:resource].is_a?(String) || options[:resource].is_a?(Symbol)
      raise TypeError, "Invalid argument type. Expected Integer, got #{options[:id].class.name}" if options.key?(:id) && !options[:id].is_a?(Integer)
      raise TypeError, "Invalid argument type. Expected Boolean" if options[:show_endpoint] && ![true, false].include?(options[:show_endpoint])
      validate_body(options)
    end

    def validate_body(options)
      return unless options.key?(:data)
      raise TypeError, "Invalid argument type. Expected Hash, got #{options[:data].class.name}" unless options[:data].is_a?(Hash)
    end

    def build_endpoint(options)
      Endpoint::Builder.new(options).call
    end

    def format_data(data, options = {})
      Formatter.new(options).call(data)
    end
  end
end
