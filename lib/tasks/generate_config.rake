namespace :strapi_ruby do
  desc "Generate a default configuration file"
  task :install do
    # Directory path for the config directory
    config_dir = File.join(File.dirname(__FILE__), "config")

    # Check if the 'config' directory exists, and create it if not
    Dir.mkdir(config_dir) unless File.directory?(config_dir)

    # Configuration file path
    config_file = File.join(config_dir, "strapi_ruby.rb")

    # Check if the configuration file exists, and create it with default content if not
    unless File.exist?(config_file)
      # Define the configuration data (contents of strapi_ruby.rb)
      config = <<-CONFIG
  # Your StrapiRuby configuration goes here
  StrapiRuby.configure do |config|
    config.strapi_server_uri = "http://localhost:1337"
    config.strapi_token = "YOUR_TOKEN"
    # Check documentation for more configuration options
    # https://github.com/saint-james-fr/strapi_ruby
  end
      CONFIG

      File.write(config_file, config)
    end
  end
end
