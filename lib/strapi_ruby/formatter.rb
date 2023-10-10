module StrapiRuby
  class Formatter
    def initialize(options = {})
      @keys_to_convert = options[:convert_to_html] || StrapiRuby.config.convert_to_html
    end

    def call(data)
      # Check data for emptiness
      check_emptiness(data)

      converted_data = data.clone
      convert_to_html!(converted_data)
      convert_to_datetime!(converted_data)
      converted_data
    end

    private

    def convert_to_datetime!(data)
      return unless StrapiRuby.config.convert_to_datetime

      if collection?(data)
        data.each { |item| parse_into_datetime!(item.attributes) }
      else
        parse_into_datetime!(data.attributes)
      end
    end

    def parse_into_datetime!(attributes)
      traverse_struct_and_change_key!(attributes, "createdAt")
      traverse_struct_and_change_key!(attributes, "publishedAt")
      traverse_struct_and_change_key!(attributes, "updatedAt")
    end

    def traverse_struct_and_change_key!(struct, key_to_check, path = [])
      struct.each_pair do |key, value|
        current_path = path + [key]

        struct.send("#{key}=", DateTime.parse(struct.send(key_to_check.to_sym))) if key.to_s == key_to_check && struct.respond_to?(key_to_check.to_sym)

        if value.is_a?(OpenStruct)
          traverse_struct_and_change_key!(value, key_to_check, current_path)
        elsif value.is_a?(Array)
          value.each_with_index do |item, index|
            traverse_struct_and_change_key!(item, key_to_check, current_path + [index]) if item.is_a?(OpenStruct)
          end
        end
      end
    end

    def check_emptiness(data)
      if collection?(data)
        data if data.all? { |item| item.to_h.empty? }
      elsif data.to_h.empty?
        data
      end
    end

    def collection?(data)
      data.is_a?(Array)
    end

    def convert_to_html!(data)
      if collection?(data)
        data.each { |item| convert_attributes!(item.attributes) }
      else
        convert_attributes!(data.attributes)
      end
    end

    def convert_attributes!(attributes)
      # Loop through the methods of the attributes
      attributes.methods.map do |method|
        # Check if the method is in the keys to convert
        next unless @keys_to_convert.include?(method)

        # Get the value of the method
        method_value = attributes.send(method)
        # Convert and set the value of the method
        attributes.send("#{method}=", convert_value_to_html(method_value))
      end
    end

    def convert_value_to_html(value)
      Markdown.instance.to_html(value)
    end
  end
end
