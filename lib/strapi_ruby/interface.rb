module StrapiRuby
  module Interface
    include StrapiRuby::Validations

    def get(options = {})
      request(:get, options)
    end

    def post(options = {})
      request(:post, options)
    end

    def put(options = {})
      request(:put, options)
    end

    def delete(options = {})
      request(:delete, options)
    end

    def escape_empty_answer(answer)
      return answer.error.message if answer.data.nil? && answer.error

      yield
    end

    private

    def request(http_verb, options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)
      answer = build_answer(http_verb, @endpoint, options)
      data = format_data(answer.data, options)
      meta = answer.meta

      return_success_open_struct(data, meta, options)
    rescue StrapiRuby::ClientError, StrapiRuby::ConfigurationError => e
      return_error_open_struct(e, options)
    end

    def build_answer(http_verb, endpoint, options)
      if %i[get delete].include?(http_verb)
        @client.public_send(http_verb, endpoint)
      else
        validate_data_presence(options)
        body = options[:data]
        @client.public_send(http_verb, endpoint, body)
      end
    end

    def show_endpoint?(options)
      options[:show_endpoint] || StrapiRuby.config.show_endpoint
    end

    def return_success_open_struct(data, meta, _error = nil, options = {})
      if show_endpoint?(options)
        OpenStruct.new(data: data,
                       meta: meta,
                       endpoint: @endpoint).freeze
      else
        OpenStruct.new(data: data, meta: meta).freeze
      end
    end

    def return_error_open_struct(error, _options = {})
      OpenStruct.new(error: OpenStruct.new(message: "#{error.class}: #{error.message}"),
                     endpoint: @endpoint,
                     data: nil,
                     meta: nil).freeze
    end

    def build_endpoint(options)
      Endpoint::Builder.new(options).call
    end

    def format_data(data, options = {})
      Formatter.new(options).call(data)
    end
  end
end
