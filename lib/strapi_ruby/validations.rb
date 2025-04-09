module StrapiRuby
  module Validations
    def validate_data_presence(options)
      raise ArgumentError, ErrorMessage.missing_data unless options.key?(:data)
    end

    def validate_config(config)
      validate_mandatory_config_params(config.strapi_server_uri, config.strapi_token)
      validate_faraday_block(config.faraday)
      validate_show_endpoint_config(config.show_endpoint)
      validate_convert_to_html(config.convert_to_html)
    end

    def validate_options(options)
      validate_config_presence
      validate_resource(options)
      validate_document_id(options)
      validate_show_endpoint_params(options)
      validate_body(options)
    end

    private

    def validate_convert_to_html(convert_to_html)
      raise TypeError, "#{ErrorMessage.expected_array}. Got #{convert_to_html.class.name}" unless convert_to_html.is_a?(Array)
    end

    def validate_show_endpoint_config(show_endpoint)
      raise TypeError, ErrorMessage.expected_boolean unless [true, false].include?(show_endpoint)
    end

    def validate_faraday_block(faraday)
      raise TypeError, "#{ErrorMessage.expected_proc} Got #{faraday.class.name}" if !faraday.nil? && !faraday.is_a?(Proc)
    end

    def validate_mandatory_config_params(strapi_server_uri, strapi_token)
      raise ConfigurationError, ErrorMessage.missing_strapi_server_uri if strapi_server_uri.nil? || strapi_server_uri.empty?
      raise ConfigurationError, ErrorMessage.missing_strapi_token if strapi_token.nil? || strapi_token.empty?
    end

    def validate_config_presence
      raise ConfigurationError, ErrorMessage.missing_configuration if @config.nil?
    end

    def validate_resource(options)
      raise ArgumentError, ErrorMessage.missing_resource unless options.key?(:resource)
      raise TypeError, "#{ErrorMessage.expected_string_symbol} Got #{options[:resource].class.name}" unless options[:resource].is_a?(String) || options[:resource].is_a?(Symbol)
    end

    def validate_document_id(options)
      raise TypeError, "#{ErrorMessage.expected_integer} Got #{options[:document_id].class.name}" if options.key?(:document_id) && !options[:document_id].is_a?(String)
    end

    def validate_show_endpoint_params(options)
      raise TypeError, ErrorMessage.expected_boolean if options[:show_endpoint] && ![true, false].include?(options[:show_endpoint])
    end

    def validate_body(options)
      return unless options.key?(:data)
      raise TypeError, "#{ErrorMessage.expected_hash} Got #{options[:data].class.name}" unless options[:data].is_a?(Hash)
    end
  end
end
