namespace :strapi_ruby do
  desc "Generates a configuration file within Rails applications"
  task :config do
    # Directory path for the config directory
    initializers_dir = File.join(Rails.root, "config", "initializers")

    # Configuration file path
    config_file = File.join(initializers_dir, "strapi_ruby.rb")

    # Check if the configuration file exists, and create it with default content if not
    if File.exist?(config_file)
      puts "StrapiRuby configuration file already exists."
    else
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
      puts "StrapiRuby configuration file created at config/initializers/strapi_ruby.rb."
    end
  end
end
