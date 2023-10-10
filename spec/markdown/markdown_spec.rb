# frozen_string_literal: true

RSpec.describe StrapiRuby::Markdown do
  let(:markdown) { described_class.instance }

  describe "#to_html" do
    it "converts Markdown to HTML" do
      expect(markdown.to_html("# Hello, world!")).to eq("<h1>Hello, world!</h1>\n")
    end
  end
end
