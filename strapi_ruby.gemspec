# frozen_string_literal: true

require_relative "lib/strapi_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "strapi_ruby"
  spec.version = StrapiRuby::VERSION
  spec.authors = ["Maxence Robinet"]
  spec.email = ["contact@maxencerobinet.fr"]

  spec.summary = "Ruby wrapper around Strapi API."
  spec.description = <<-DESC
  StrapiRuby is a Ruby gem designed to simplify interactions
  with the Strapi CMS API. It provides an easy-to-use interface for
  making requests to a Strapi server and handling responses.
  DESC

  spec.homepage = "https://github.com/saint-james-fr/strapi_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/saint-james-fr/strapi_ruby/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday", "~> 2.7"
  spec.add_dependency "redcarpet", "~> 3.6"

  spec.add_development_dependency "dotenv", "~> 2.8"
  spec.add_development_dependency "webmock", "~> 3.19"
end
