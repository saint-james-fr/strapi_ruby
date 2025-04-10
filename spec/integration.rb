require_relative "../lib/strapi_ruby"
require "dotenv"

Dotenv.load

# To run this test, just run ruby spec/integration.rb from root
# 1. It will need a Strapi Server
# 2. StrapiRuby configuration shall be provided
# 3. See at the end of the file the tests to run

# ON STRAPI
# Create a Content-type called "articles" with a "title" and "content" field
# and create three articles to test the API
# use these titles: "my first article", "my second article", "my third article"
# use a featuredMedia field to test the populate feature, at least on the first article

# Configure StrapiRuby
def configure_strapi
  StrapiRuby.configure do |config|
    config.strapi_server_uri = ENV["STRAPI_SERVER_URI"]
    config.strapi_token = ENV["STRAPI_TOKEN"]
    config.convert_to_html = [:content]
    config.show_endpoint = true
  end
end

# Test fetching all articles
def test_get_all_articles
  test_get = StrapiRuby.get(resource: "articles")
  test_get
end

# Test fetching one article
def test_get_one_article
  test_get = StrapiRuby.get(resource: "articles", documentId: "1")
  test_get
end

# Test pagination
def test_pagination
  # Create 4 articles
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my first article", content: "This is some dummy content" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "This is my second article", content: "This is some dummy content" })
  third_article = StrapiRuby.post(resource: "articles", data: { title: "This is my third article", content: "This is some dummy content" })
  fourth_article = StrapiRuby.post(resource: "articles", data: { title: "This is my fourth article", content: "This is some dummy content" })
  test_get = StrapiRuby.get(resource: "articles", page: 1, page_size: 2)
  p "test_pagination: #{test_get.data.count == 2}"
  # Delete the articles
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: third_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: fourth_article.data.documentId)
end

# Test sorting
def test_sorting
  test_get = StrapiRuby.get(resource: "articles", sort: ["createdAt:desc", "title:asc"])
  test_get.data.map do |item|
    item.createdAt
  end
  # data should be sorted by createdAt descending and title ascending
  # the first item should have the highest createdAt and the lowest title
  first_item = test_get.data.first
  last_item = test_get.data.last
  p "test_sorting: #{first_item.createdAt > last_item.createdAt}"
  p "test_sorting: #{first_item.title < last_item.title}"
end

# Test filtering
def test_filtering
  # Make sure we have at least 3 articles: this test is dependent on the test_post_article test and test_delete_article test
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my fourth article", content: "This is some dummy content" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "This is my fifth article", content: "This is some dummy content" })
  third_article = StrapiRuby.post(resource: "articles", data: { title: "This is my sixth article", content: "This is some dummy content" })

  test_get = StrapiRuby.get(resource: "articles", fields: :title, filters: { documentId: { "$in" => [first_article.data.documentId, third_article.data.documentId] } })
  test_get.data
  p "test_filtering: #{test_get.data.count == 2}"
  # delete the articles
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: third_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
end

# Test complex filtering
def test_complex_filtering
  # Create an article with the following data:
  first_article = StrapiRuby.post(resource: "articles", data: { title: "Babar", content: "Aventure au pays des éléphants" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "Tintin", content: "Objectif lune" })
  third_article = StrapiRuby.post(resource: "articles", data: { title: "Astérix", content: "La table des dieux" })
  fourth_article = StrapiRuby.post(resource: "articles", data: { title: "Batman", content: "Gotham ne deviendra pas une victime" })

  # Adjust the filters to match the fields in your articles
  test_get = StrapiRuby.get(resource: :articles,
                            filters: {
                              "$or" => [
                                {
                                  title: {
                                    "$eq" => "Babar",
                                  },
                                },
                                {
                                  title: {
                                    "$eq" => "Tintin", # Tintin
                                  },
                                },
                                {
                                  content: {
                                    "$eq" => "Gotham ne deviendra pas une victime", # Aventure au pays des éléphants
                                  },
                                },
                              ],
                            })

  p "test_complex_filtering: #{test_get.data.count == 3}"

  test_get_2 = StrapiRuby.get(resource: :articles,
                              filters: {
                                "$or" => [
                                  { title: { "$eq" => "Batman" } },
                                  { title: { "$eq" => "Tintin" } },
                                ],
                                content: {
                                  "$eq" => "Gotham ne deviendra pas une victime",
                                },
                              })

  p "test_complex_filtering_2: #{test_get_2.data.count == 1}"

  # Delete the articles
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: third_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: fourth_article.data.documentId)
end

# Test raw query
def test_raw_query
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my first article", content: "This is some dummy content" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "This is my second article", content: "This is some dummy content" })
  third_article = StrapiRuby.post(resource: "articles", data: { title: "This is my third article", content: "This is some dummy content" })
  test_get = StrapiRuby.get(resource: "articles", raw: "?fields=title&sort=createdAt:desc")
  p "test_raw_query: #{test_get.data.count == 3}"
  p "test_raw_query: #{test_get.data.first.title == "This is my third article"}"
  p "test_raw_query: #{test_get.data.last.title == "This is my first article"}"

  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: third_article.data.documentId)
end

# Test offset pagination
def test_offset_pagination
  # Create 4 articles
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my first article", content: "This is some dummy content" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "This is my second article", content: "This is some dummy content" })
  third_article = StrapiRuby.post(resource: "articles", data: { title: "This is my third article", content: "This is some dummy content" })
  fourth_article = StrapiRuby.post(resource: "articles", data: { title: "This is my fourth article", content: "This is some dummy content" })
  test_get = StrapiRuby.get(resource: "articles", start: 2, limit: 1)
  test_get.data
  p "test_offset_pagination: #{test_get.data.count == 1}"
  # delete the articles
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: third_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: fourth_article.data.documentId)
end

# Test locale: this won't work if you don't create the local on strapi in settings then enable it in on your collection type advanced settings
def test_locale
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my japanese article", content: "some japanese content", locale: "ja" })
  second_article = StrapiRuby.post(resource: "articles", data: { title: "This is my italian article", content: "some italian content", locale: "it" })
  test_get = StrapiRuby.get(resource: "articles", locale: "ja")
  test_get.data
  p "test_locale: #{test_get.data.count == 1}"
  test_get = StrapiRuby.get(resource: "articles", locale: "it")
  test_get.data
  p "test_locale: #{test_get.data.count == 1}"
  # delete the articles
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
  StrapiRuby.delete(resource: "articles", document_id: second_article.data.documentId)
end

# Test selecting fields
def test_selecting_fields
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my first article", content: "This is some dummy content" })
  test_get = StrapiRuby.get(resource: :articles, fields: [:title])
  # Should not contain content field
  p "test_selecting_fields: #{test_get.data.first.content.nil?}"
  p "test_selecting_fields: #{!test_get.data.first.title.nil? && !test_get.data.first.title.empty?}"
  # Delete the article
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
end

# Test populate: add featuredMedia field to the article and see if its populated
def test_populate
  first_article = StrapiRuby.post(resource: "articles", data: { title: "This is my first article", content: "This is some dummy content" })
  test_get = StrapiRuby.get(resource: :articles, populate: :*)
  test_get.data.first.featuredMedia
  # Delete the article
  StrapiRuby.delete(resource: "articles", document_id: first_article.data.documentId)
end

# Test a 404 endpoint: this will fail poorly
def test_404_endpoint
  answer = StrapiRuby.get(resource: "thisDoesNotExist")
end

# Test post article
def test_post_article
  StrapiRuby.post(resource: "articles", data: { title: "This is my fourth article", content: "This is some dummy content" })
end

# Test put article
def test_put_article
  document_id = StrapiRuby.get(resource: "articles", sort: "createdAt:asc").data.last.documentId
  StrapiRuby.put(resource: "articles", document_id: document_id, data: { title: "Title has been changed by PUT request" })
end

# Test delete article
def test_delete_article
  document_id = StrapiRuby.get(resource: "articles", sort: "createdAt:asc").data.last.documentId
  StrapiRuby.delete(resource: "articles", document_id: document_id)
end

def test_show_endpoint
  endpoint = StrapiRuby.get(resource: "articles", filters: { documentId: { "$in" => ["someId", "someOtherId"] } }, show_endpoint: true).endpoint
  p "test_show_endpoint: #{endpoint.include?("http://localhost:1337/api/articles?filters[documentId][$in][0]=someId&filters[documentId][$in][1]=someOtherId")}"
end

def test_escape_empty_answer
  answer = StrapiRuby.get(resource: "articles", document_id: "thisDoesNotExist")

  StrapiRuby.escape_empty_answer(answer) do
    puts "if you see this, it means the test is not passing"
    return
  end
  puts "if you see this, it means the test is passing"
  answer
end

# Main execution
configure_strapi
puts "\n\n"

# Uncomment and run the desired test functions here
tests = [
  :test_post_article,
  :test_get_all_articles,
  :test_get_one_article,
  :test_put_article,
  :test_delete_article,
  :test_sorting,
  :test_filtering,
  :test_complex_filtering,
  :test_pagination,
  :test_offset_pagination,
  :test_locale,
  :test_selecting_fields,
  :test_populate,
  :test_raw_query,
  :test_404_endpoint,
  :test_show_endpoint,
  :test_escape_empty_answer,
]

tests.each do |test|
  puts "\n\n"
  puts "#{test} result:"
  test_result = send(test)
  puts "\n"
  p test_result
  puts "\n"
end
