# frozen_string_literal: true
require "ostruct"

require_relative "strapi_ruby/version"
require_relative "strapi_ruby/validations"
require_relative "strapi_ruby/endpoint/builder"
require_relative "strapi_ruby/endpoint/strapi_parameters"
require_relative "strapi_ruby/endpoint/query"
require_relative "strapi_ruby/markdown"
require_relative "strapi_ruby/formatter"
require_relative "strapi_ruby/interface"
require_relative "strapi_ruby/client"
require_relative "strapi_ruby/configuration"
require_relative "strapi_ruby/config"

# Load errors
require_relative "strapi_ruby/errors/logger"
require_relative "strapi_ruby/errors/client_error"
require_relative "strapi_ruby/errors/configuration_error"
require_relative "strapi_ruby/errors/error_message"

# Load Rake tasks within Rails applications
require_relative "strapi_ruby/railtie" if defined?(Rails)

module StrapiRuby
  extend Configuration
  extend Interface
end
