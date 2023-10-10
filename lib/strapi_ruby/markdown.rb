require "singleton"
require "redcarpet"

# Use with Markdown.instance.to_html

module StrapiRuby
  class Markdown
    include Singleton

    def to_html(markdown)
      markdown_renderer.render(markdown)
    end

    private

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, { autolink: true })
    end
  end
end
