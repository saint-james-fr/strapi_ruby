module StrapiRuby
  class Railtie < Rails::Railtie
    railtie_name :strapi_ruby

    if defined?(Rake)
      rake_tasks do
        path = File.expand_path(__dir__)
        Dir.glob("#{path}/tasks/**/*.rake").each { |f| load f }
      end
    end
  end
end
