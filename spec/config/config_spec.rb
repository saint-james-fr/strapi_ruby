RSpec.describe StrapiRuby::Config do
  let(:config) { described_class.new }
  describe "#initialize" do
    context "when @faraday is a Proc" do
      it "does not raise an ArgumentError" do
        faraday_proc = Proc.new { puts "I'm a Proc" }
        config.strapi_server_uri = "https://example.com"
        config.strapi_token = "124"
        config.faraday = faraday_proc
        expect { config.validate! }.not_to raise_error
      end
    end

    context "when @faraday is not a Proc" do
      it "does not raise an ArgumentError" do
        faraday_string = "I'm a string"
        config.strapi_server_uri = "https://example.com"
        config.strapi_token = "124"
        config.faraday = faraday_string
        expect { config.validate! }.to raise_error(TypeError)
      end
    end

    context "when @strapi_server_uri is nil" do
      it "raises a ConfigurationError" do
        config.strapi_server_uri = nil
        config.strapi_token = "124"
        config.faraday = Proc.new { puts "I'm a Proc" }
        expect { config.validate! }.to raise_error(StrapiRuby::ConfigurationError)
      end
    end
    context "when @strapi_server_uri is empty" do
      it "raises a ConfigurationError" do
        config.strapi_server_uri = ''
        config.strapi_token = "124"
        config.faraday = Proc.new { puts "I'm a Proc" }
        expect { config.validate! }.to raise_error(StrapiRuby::ConfigurationError)
      end
    end

    context "when @strapi_token is nil" do
      it "raises a ConfigurationError" do
        config.strapi_server_uri = 'example.com'
        config.strapi_token = nil
        config.faraday = Proc.new { puts "I'm a Proc" }
        expect { config.validate! }.to raise_error(StrapiRuby::ConfigurationError)
      end
    end
    context "when @strapi_token is empty" do
      it "raises a ConfigurationError" do
        config.strapi_server_uri = 'example.com'
        config.strapi_token = ""
        config.faraday = Proc.new { puts "I'm a Proc" }
        expect { config.validate! }.to raise_error(StrapiRuby::ConfigurationError)
      end
    end
  end
end
