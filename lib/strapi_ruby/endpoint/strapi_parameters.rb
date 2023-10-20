require "uri"

module StrapiRuby
  module Endpoint
    module StrapiParameters
      private

      def sort(args)
        check_collection
        build_query_from_args(args, :sort)
      end

      def fields(args)
        build_query_from_args(args, :fields)
      end

      def populate(args)
        build_query_from_args(args, :populate)
      end

      def filters(args)
        check_collection
        build_query_from_args(args, :filters)
      end

      def page_size(number)
        raise TypeError, "#{ErrorMessage.expected_integer} Got #{number.class.name}" unless number.is_a?(Integer)

        check_single_pagination
        check_collection
        @result += "#{prefix}pagination[pageSize]=#{number}"
      end

      def page(number)
        raise TypeError, "#{ErrorMessage.expected_integer} Got #{number.class.name}" unless number.is_a?(Integer)

        check_single_pagination
        check_collection
        @result += "#{prefix}pagination[page]=#{number}"
      end

      def start(number)
        raise TypeError, "#{ErrorMessage.expected_integer} Got #{number.class.name}" unless number.is_a?(Integer)

        check_single_pagination
        check_collection
        @result += "#{prefix}pagination[start]=#{number}"
      end

      def limit(number)
        raise TypeError unless number.is_a?(Integer)

        check_single_pagination
        check_collection
        @result += "#{prefix}pagination[limit]=#{number}"
      end

      def locale(arg)
        raise TypeError, "#{ErrorMessage.expected_string_symbol} Got #{arg.class.name}" unless arg.is_a?(String) || arg.is_a?(Symbol)

        check_collection

        @result += "#{prefix}locale=#{arg}"
      end

      def publication_state(arg)
        raise TypeError, "#{ErrorMessage.expected_string_symbol} Got #{arg.class.name}" unless arg.is_a?(String) || arg.is_a?(Symbol)
        raise ArgumentError, "#{ErrorMessage.publication_state} Got #{arg}" unless arg.to_sym == :live || arg.to_sym == :preview

        check_collection

        @result += "#{prefix}publicationState=#{arg}"
      end

      def check_single_pagination
        return unless (@options.key?(:page) && @options.key?(:start)) ||
                      (@options.key(:page) && @options.key?(:limit)) ||
                      (@options.key(:pagination) && options.key?(:start)) ||
                      (@options.key(:pagination) && options.key?(:limit))

        raise ArgumentError, ErrorMessage.pagination
      end

      def collection?
        @options[:id].nil?
      end

      def check_collection
        return if collection?

        raise ArgumentError, ErrorMessage.collection_query
      end

      def prefix
        @result.empty? ? "?" : "&"
      end

      def build_query_from_args(args, method_name)
        query = prefix
        hash = {}
        hash[method_name] = args
        query += traverse_hash(hash)
        @result += query
      end

      def traverse_hash(hash, parent_key = nil)
        hash.map do |key, value|
          current_key = parent_key ? "#{parent_key}[#{key}]" : key.to_s

          if value.is_a?(Hash)
            traverse_hash(value, current_key)
          elsif value.is_a?(Array)
            value.map.with_index do |item, index|
              traverse_hash({ index => item }, current_key)
            end
          else
            # We can pass values as symbols but we need to convert them to string
            # to be able to escape them
            value = value.to_s if value.is_a?(Symbol)
            "#{current_key}=#{CGI.escape(value)}"
          end
        end.join("&")
      end
    end
  end
end
