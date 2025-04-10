# frozen_string_literal: true

RSpec.describe StrapiRuby::Formatter do
  before do
    html_value = "<p>Mocked content</p>\n"
    allow(data).to receive(:content).and_return(html_value)
    allow(data).to receive(:content=).with(html_value)
  end

  describe "#convert_to_html!" do
    let(:convert_to_html_keys) { [:content] }
    let(:data) { OpenStruct.new(content: "Mocked content", title: "# Mocked title") }
    let(:data_collection) { [data, data] }
    let(:empty_data) { OpenStruct.new }
    let(:formatter) { StrapiRuby::Formatter.new({ convert_to_html: convert_to_html_keys }) }

    context "when data is a single item" do
      context "and when the key matches" do
        it "should convert data to HTML" do
          converted_content = "<p>Mocked content</p>\n"
          formatter.send(:convert_to_html!, data)
          expect(data.content).to eq(converted_content)
        end
      end

      context "and when the key does not match" do
        it "should not convert data to HTML if data.key is the same" do
          converted_title = "<h1>Mocked title</h1>\n"
          formatter.send(:convert_to_html!, data)
          expect(data.title).not_to eq(converted_title)
        end
      end
    end

    context "when data is a collection" do
      context "and when the key matches" do
        it "should convert each data to HTML" do
          converted_content = "<p>Mocked content</p>\n"
          formatter.send(:convert_to_html!, data_collection)
          data_collection.each do |converted_data|
            expect(converted_data.content).to eq(converted_content)
          end
        end
      end

      context "and when the key does not match" do
        it "should not convert each data to HTML" do
          converted_title = "<h1>Mocked title</h1>\n"
          formatter.send(:convert_to_html!, data_collection)
          data_collection.each do |converted_data|
            expect(converted_data.title).not_to eq(converted_title)
          end
        end
      end
    end
  end

  describe "#convert_to_datetime!" do
    let(:formatter) { StrapiRuby::Formatter.new }
    let(:data) { OpenStruct.new(createdAt: "2023-10-04T12:34:56.000Z", updatedAt: "2023-10-04T13:45:30.000Z", publishedAt: "2023-10-04T14:56:12.000Z") }

    context "when data contain ISO date strings" do
      it "parses createdAt attribute into DateTime" do
        formatter.send(:convert_to_datetime!, data)
        expect(data.createdAt).to be_a(DateTime)
      end

      it "parses updatedAt attribute into DateTime" do
        formatter.send(:convert_to_datetime!, data)
        expect(data.updatedAt).to be_a(DateTime)
      end

      it "parses publishedAt attribute into DateTime" do
        formatter.send(:convert_to_datetime!, data)
        expect(data.publishedAt).to be_a(DateTime)
      end
    end
  end
end
