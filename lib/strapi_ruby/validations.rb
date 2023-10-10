module StrapiRuby
  module Validations
    def validate_data_presence(options)
      raise ArgumentError, ErrorMessage.missing_data unless options.key?(:data)
    end

    def validate_options(options)
      validate_config_presence
      validate_resource
      validate_id
      validate_show_endpoint
      validate_body(options)
    end

    private

    def validate_config_presence
      raise ConfigurationError, ErrorMessage.missing_configuration if @config.nil?
    end

    def validate_resource
      raise ArgumentError, ErrorMessage.missing_resource unless options.key?(:resource)
      raise TypeError, "Invalid argument type. Expected String or Symbol, got #{options[:resource].class.name}" unless options[:resource].is_a?(String) || options[:resource].is_a?(Symbol)
    end

    def validate_id
      raise TypeError, "Invalid argument type. Expected Integer, got #{options[:id].class.name}" if options.key?(:id) && !options[:id].is_a?(Integer)
    end

    def validate_show_endpoint
      raise TypeError, "Invalid argument type. Expected Boolean" if options[:show_endpoint] && ![true, false].include?(options[:show_endpoint])
    end

    def validate_body(options)
      return unless options.key?(:data)
      raise TypeError, "Invalid argument type. Expected Hash, got #{options[:data].class.name}" unless options[:data].is_a?(Hash)
    end
  end
end
