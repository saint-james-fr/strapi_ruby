require_relative "../lib/strapi_ruby"
require "dotenv"

Dotenv.load

# Configure StrapiRuby
def configure_strapi
  StrapiRuby.configure do |config|
    config.strapi_server_uri = ENV["STRAPI_SERVER_URI"]
    config.strapi_token = ENV["STRAPI_TOKEN"]
    config.show_endpoint = true
  end
end

# ON STRAPI
# Create a Content-type called "articles" with a "title" and "content" field
# and create three articles to test the API
# use these titles: "my first article", "my second article", "my third article"
# use a featuredMedia field to test the populate feature, at least on the first article

# Test fetching all articles
def test_get_all_articles
  test_get = StrapiRuby.get(resource: "articles")
  test_get.data
end

# Test fetching one article
def test_get_one_article
  test_get = StrapiRuby.get(resource: "articles", id: 1)
  test_get.data
end

# Test pagination
def test_pagination
  test_get = StrapiRuby.get(resource: "articles", page: 1, page_size: 2)
  test_get.data.count
end

# Test sorting
def test_sorting
  test_get = StrapiRuby.get(resource: "articles", sort: ["createdAt:desc", "title:asc"])
  test_get.data.map do |item|
    item.attributes.createdAt
  end
end

# Test filtering
def test_filtering
  test_get = StrapiRuby.get(resource: "articles", fields: :title, filters: { id: { "$in" => ["1", "3"] } })
  test_get.data
end

# Test complex filtering
def test_complex_filtering
  test_get = StrapiRuby.get(resource: "articles", fields: :title, filters: {
                              "$or" => [
                                { title: { "$contains" => "third" } },
                                { title: { "$contains" => "second" } },
                              ],
                            })
  test_get.data
end

# Test raw query
def test_raw_query
  test_get = StrapiRuby.get(resource: "articles", raw: "?fields=title&sort=createdAt:asc")
  test_get.data.map do |item|
    item.attributes.title
  end
end

# Test offset pagination
def test_offset_pagination
  test_get = StrapiRuby.get(resource: "articles", start: 0, limit: 1)
  test_get.data
end

# Test locale
def test_locale
  test_get = StrapiRuby.get(resource: "articles", locale: :en)
  test_get.data
end

# Test selecting fields
def test_selecting_fields
  test_get = StrapiRuby.get(resource: :articles, fields: [:title])
  test_get.data
end

# Test populate
def test_populate
  test_get = StrapiRuby.get(resource: :articles, populate: :*)
  test_get.data.first.attributes.featuredMedia
end

# Test a 404 endpoint
def test_404_endpoint
  begin
    test_get = StrapiRuby.get(resource: "thisDoesNotExist")
    test_get.data.count
  rescue StrapiRuby::NotFoundError => e
    puts e.message
    puts "404 endpoint test passed"
  end
end

# Test post article
def test_post_article
  StrapiRuby.post(resource: "articles", data: { title: "This is my fourth article", content: "This is some dummy content" })
end

# Test put article
def test_put_article
  id = StrapiRuby.get(resource: "articles", sort: "createdAt:asc").data.last.id
  StrapiRuby.put(resource: "articles", id: id, data: { title: "Title has been changed by PUT request" })
end

# Test delete article
def test_delete_article
  id = StrapiRuby.get(resource: "articles", sort: "createdAt:asc").data.last.id
  StrapiRuby.delete(resource: "articles", id: id)
end

def test_show_endpoint
  StrapiRuby.get(resource: "articles", show_endpoint: true).endpoint
end

# Main execution
configure_strapi
puts "\n\n"

# Uncomment and run the desired test functions here
tests = [
  :test_get_all_articles,
  :test_get_one_article,
  :test_post_article,
  :test_put_article,
  :test_delete_article,
  # :test_sorting,
  # :test_filtering,
  # :test_complex_filtering,
  # :test_pagination,
  # :test_offset_pagination,
  # :test_locale,
  # :test_selecting_fields,
  # :test_populate,
  # :test_raw_query,
  # :test_404_endpoint,
  # :test_show_endpoint,raise_error(ArgumentError)

]

tests.each do |test|
  puts "\n\n"
  puts "#{test} result:"
  test_result = send(test)
  puts "\n"
  p test_result
  puts "\n"
end
