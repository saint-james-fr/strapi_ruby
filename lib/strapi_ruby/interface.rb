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

    private

    def request(http_verb, options = {})
      validate_options(options)
      @endpoint = build_endpoint(options)

      answer = if %i[get delete].include?(http_verb)
          @client.public_send(http_verb, @endpoint)
        else
          validate_data_presence(options)
          body = options[:data]
          @client.public_send(http_verb, @endpoint, body)
        end

      data = format_data(answer.data, options)
      meta = answer.meta

      format_answer_in_open_struct(data, meta, options)
    end

    def format_answer_in_open_struct(data, meta, options = {})
      if options[:show_endpoint] || StrapiRuby.config.show_endpoint
        OpenStruct.new(data: data, meta: meta, endpoint: @endpoint)
      else
        OpenStruct.new(data: data, meta: meta)
      end
    end

    def build_endpoint(options)
      Endpoint::Builder.new(options).call
    end

    def format_data(data, options = {})
      Formatter.new(options).call(data)
    end
  end
end
