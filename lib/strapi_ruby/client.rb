require "faraday"
require "json"

module StrapiRuby
  class Client
    attr_reader :connection

    def initialize(options = {}, &block)
      @connection = set_connection(options, &block)
    end

    def get(endpoint)
      response = performs_request { @connection.get(endpoint) }
      handle_response(response)
    end

    def post(endpoint, body)
      response = performs_request { @connection.post(endpoint, build_data_payload(body)) }
      handle_response(response)
    end

    def put(endpoint, body)
      response = performs_request { @connection.put(endpoint, build_data_payload(body)) }
      handle_response(response)
    end

    def delete(endpoint)
      response = performs_request { @connection.delete(endpoint) }
      handle_response(response)
    end

    private

    def set_connection(options, &block)
      url = options[:strapi_server_uri]
      strapi_token = options[:strapi_token]

      default_headers = { "Content-Type" => "application/json",
                          "Authorization" => "Bearer #{strapi_token}",
                          "User-Agent" => "StrapiRuby/#{StrapiRuby::VERSION}" }

      Faraday.new(url: url) do |faraday|
        # Use FlatParamsEncoder to prevent double encoding of special characters
        faraday.options.params_encoder = Faraday::FlatParamsEncoder
        faraday.adapter Faraday.default_adapter
        block&.call(faraday)
        faraday.headers = default_headers.merge(faraday.headers)
      end
    end

    def performs_request
      yield
    rescue Faraday::ConnectionFailed => e
      raise ConnectionError, "#{ErrorMessage.connection_failed} #{e.message}"
    rescue Faraday::TimeoutError => e
      raise ConnectionError, "#{ErrorMessage.timeout} #{e.message}"
    rescue StandardError => e
      raise ConnectionError, "#{ErrorMessage.unexpected} #{e.message}"
    end

    def convert_json_to_open_struct(json)
      JSON.parse(json, object_class: OpenStruct)
    rescue JSON::ParserError => e
      raise JSONParsingError, e.message
    end

    def build_data_payload(body)
      { data: body }.to_json
    end

    # rubocop:disable Metrics/AbcSize
    def handle_response(response)
      body = convert_json_to_open_struct(response.body) unless response.body.empty?
      case response.status
      when 200, 201
        body
      when 400
        raise BadRequestError.new(body.error.message, response.status)
      when 401
        raise UnauthorizedError.new(body.error.message, response.status)
      when 403
        raise ForbiddenError.new(body.error.message, response.status)
      when 404
        raise NotFoundError.new(body.error.message, response.status)
      when 422
        raise UnprocessableEntityError.new(body.error.message, response.status)
      when 500..599
        raise ServerError.new(body.error.message, response.status)
      end
    end

    # rubocop:enable Metrics/AbcSize
  end
end
