# frozen_string_literal: true

RSpec.describe StrapiRuby::Client do
  let(:client) { StrapiRuby::Client.new(strapi_server_uri: "https://www.example.com") }

  before do
    stub_request(:get, "https://www.example.com/articles/1").to_return(status: 200, body: '{"data": {"attributes":{"id": 1, "title": "Example"}}}')
    stub_request(:post, "https://www.example.com/articles").to_return(status: 200, body: '{"data": {"attributes": {"title": "This is a new example"}}}')
    stub_request(:put, "https://www.example.com/articles/1").to_return(status: 200, body: '{"data": {"attributes": {"title": "This is a modified example"}}}')
    stub_request(:delete, "https://www.example.com/articles/1").to_return(status: 200, body: '{"data": {"attributes": {"title": "This is a deleted example"}}}')
  end

  describe "#get" do
    it "sends a GET request to the specified endpoint" do
      faraday_response = client.connection.get("/articles/1")
      expect(faraday_response.status).to eq(200)
    end

    it "returns an OpenStruct object" do
      response = client.get("/articles/1")
      expect(response.class).to eq(OpenStruct)
    end

    it "handles connection errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::ConnectionFailed.new("Connection failed"))
      expect { client.get("/resource") }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles timeout errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(Faraday::TimeoutError.new("Timeout Error"))
      expect { client.get("/resource") }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles other errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:get).and_raise(StandardError.new("Something bad happened"))
      expect { client.get("/resource") }.to raise_error(StrapiRuby::ConnectionError)
    end
  end

  describe "#post" do
    it "sends a POST request to the specified endpoint" do
      faraday_response = client.connection.post("/articles", { title: "This is a new example" })
      expect(faraday_response.status).to eq(200)
      response = client.post("/articles", { title: "This is a new example" })
      p
      expect(response.data.attributes.title).to eq("This is a new example")
    end

    it "returns an OpenStruct object" do
      response = client.post("/articles", { title: "This is a new example" })
      expect(response.class).to eq(OpenStruct)
    end

    it "handles connection errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::ConnectionFailed.new("Connection failed"))
      expect { client.post("/resource", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles timeout errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(Faraday::TimeoutError.new("Timeout Error"))
      expect { client.post("/resource", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles other errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:post).and_raise(StandardError.new("Something bad happened"))
      expect { client.post("/resource", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
  end

  describe "#put" do
    it "sends a PUT request to the specified endpoint" do
      faraday_response = client.connection.put("/articles/1", { title: "This is a modified example" })
      expect(faraday_response.status).to eq(200)

      response = client.put("/articles/1", { title: "This is a modified example" })
      expect(response.data.attributes.title).to eq("This is a modified example")
    end

    it "returns an OpenStruct object" do
      response = client.put("/articles/1", { title: "This is a modified example" })
      expect(response.class).to eq(OpenStruct)
    end

    it "handles connection errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:put).and_raise(Faraday::ConnectionFailed.new("Connection failed"))
      expect { client.put("/resource/1", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles timeout errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:put).and_raise(Faraday::TimeoutError.new("Timeout Error"))
      expect { client.put("/resource/1", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles other errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:put).and_raise(StandardError.new("Something bad happened"))
      expect { client.put("/resource/1", {}) }.to raise_error(StrapiRuby::ConnectionError)
    end
  end

  describe "#delete" do
    it "sends a DELETE request to the specified endpoint" do
      faraday_response = client.connection.delete("/articles/1")
      expect(faraday_response.status).to eq(200)

      response = client.delete("/articles/1")
      expect(response.data.attributes.title).to eq("This is a deleted example")
    end

    it "returns an OpenStruct object" do
      response = client.put("/articles/1", { title: "This is a deleted example" })
      expect(response.class).to eq(OpenStruct)
    end

    it "handles connection errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:delete).and_raise(Faraday::ConnectionFailed.new("Connection failed"))
      expect { client.delete("/resource/1") }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles timeout errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:delete).and_raise(Faraday::TimeoutError.new("Timeout Error"))
      expect { client.delete("/resource/1") }.to raise_error(StrapiRuby::ConnectionError)
    end
    it "handles other errors gracefully" do
      allow_any_instance_of(Faraday::Connection).to receive(:delete).and_raise(StandardError.new("Something bad happened"))
      expect { client.delete("/resource/1") }.to raise_error(StrapiRuby::ConnectionError)
    end
  end

  describe "#set_connection" do
    it "returns a Faraday::Connection object" do
      connection = client.send(:set_connection, strapi_server_uri: "https://example.com",
                                                strapi_token: "secret_strapi_token")
      expect(connection).to be_a(Faraday::Connection)
    end

    it "sets the correct headers" do
      connection = client.send(:set_connection, strapi_server_uri: "https://example.com",
                                                strapi_token: "secret_strapi_token")
      expect(connection.headers).to eq({ "Content-Type" => "application/json",
                                         "Authorization" => "Bearer secret_strapi_token", "User-Agent" => "StrapiRuby/#{StrapiRuby::VERSION}" })
    end

    it "yields to the block if given" do
      connection = client.send(:set_connection, strapi_server_uri: "https://example.com",
                                                strapi_token: "secret_strapi_token") do |faraday|
        faraday.adapter :test do |stub|
          stub.get("/test") { [200, {}, ""] }
        end
      end
      expect(connection.get("/test").status).to eq(200)
    end
  end

  describe "#handle_response" do
    context "when the response status is 200" do
      let(:response) { double(status: 200, message: "OK", body: '{"data": {"id": 1, "name": "Example"}}') }

      it "returns an OpenStruct object" do
        expect(client.send(:handle_response, response)).to be_a(OpenStruct)
      end

      it "parses the JSON data into the OpenStruct object" do
        expect(client.send(:handle_response, response).data.id).to eq(1)
        expect(client.send(:handle_response, response).data.name).to eq("Example")
      end
    end

    context "when the response status is 400" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "400"
          }
        }', status: 400 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::BadRequestError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::BadRequestError)
      end
    end

    context "when the response status is 401" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "401"
          }
        }', status: 401 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::UnauthorizedError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::UnauthorizedError)
      end
    end

    context "when the response status is 403" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "403"
          }
        }', status: 403 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::ForbiddenError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::ForbiddenError)
      end
    end

    context "when the response status is 404" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "404"
          }
        }', status: 404 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::NotFoundError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::NotFoundError)
      end
    end

    context "when the response status is 422" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "422"
          }
        }', status: 422 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::UnprocessableEntityError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::UnprocessableEntityError)
      end
    end

    context "when the response status is 500" do
      let(:error_response) do
        hash = { body: '{
          "error": {
            "message": "Something bad happened",
            "status": "500"
          }
        }', status: 500 }
        open_struct = OpenStruct.new(hash)
      end
      it "raises a StrapiRuby::ServerError" do
        expect { client.send(:handle_response, error_response) }.to raise_error(StrapiRuby::ServerError)
      end
    end

    context "when the response is not valid JSON" do
      let(:response) { double(status: 200, message: "OK", body: "not valid JSON") }

      it "raises a StrapiRuby::ResponseError" do
        expect { client.send(:handle_response, response) }.to raise_error(StrapiRuby::JSONParsingError)
      end
    end
  end
end
