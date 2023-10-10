RSpec.describe StrapiRuby do
  describe ".config" do
    it "returns a Configuration instance" do
      expect(described_class.config).to be_an_instance_of(StrapiRuby::Config)
    end

    it "returns the same instance" do
      config = described_class.config
      expect(described_class.config).to be(config)
    end
  end

  describe ".configure" do
    let(:strapi_server_uri) { "http://localhost:1337" }
    let(:strapi_token) { "secret_token" }

    before do
      described_class.configure do |config|
        config.strapi_server_uri = strapi_server_uri
        config.strapi_token = strapi_token
      end
    end

    it "sets the config options" do
      config = described_class.config
      expect(config.strapi_server_uri).to eq(strapi_server_uri)
      expect(config.strapi_token).to eq(strapi_token)
    end

    it "creates a new client instance" do
      expect(described_class.instance_variable_get(:@client)).to be_an_instance_of(StrapiRuby::Client)
    end
  end
end
