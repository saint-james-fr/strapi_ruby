namespace :strapi_ruby do
  desc "Generate a default configuration file for Rails applications"
  task :install do
    return unless defined?(Rails)
    # Directory path for the config directory
    initializers_dir = File.join(Rails.root, "config", "initializers")

    # Configuration file path
    config_file = File.join(initializers_dir, "strapi_ruby.rb")

    # Check if the configuration file exists, and create it with default content if not
    unless File.exist?(config_file)
      # Define the configuration data (contents of strapi_ruby.rb)
      config = <<-CONFIG
  # Your StrapiRuby configuration goes here
  # Check documentation for more configuration options
  # https://github.com/saint-james-fr/strapi_ruby
  StrapiRuby.configure do |config|
    config.strapi_server_uri = "YOUR_SERVER_URI"
    config.strapi_token = "YOUR_TOKEN"
  end
  CONFIG
      File.write(config_file, config)
    end
  end
end
