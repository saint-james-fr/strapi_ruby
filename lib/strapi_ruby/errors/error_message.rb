require "yaml"

module StrapiRuby
  class ErrorMessage
    class << self
      def method_missing(method_name, *_args)
        define_singleton_method(method_name) do
          text = text_yaml[method_name.to_s]
          code = code_yaml[method_name.to_s]

          build_error_message(text, code)
        end

        send(method_name)
      end

      private

      def text_yaml
        load_yaml("text")
      end

      def code_yaml
        load_yaml("code")
      end

      def load_yaml(filename)
        path = File.join(current_directory, "error_#{filename}.yml")
        YAML.load_file(path)
      end

      def current_directory
        File.dirname(__FILE__)
      end

      def build_error_message(text, code = nil)
        "\n\n#{text}\n\n#{code ? "Example:\n\n#{code}\n\n" : ""}"
      end
    end
  end
end
