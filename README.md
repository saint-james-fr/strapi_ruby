# StrapiRuby

<div align="center">
<img src="assets/strapi_ruby_logo.png" width="150px">
</div>

**StrapiRuby** is a Ruby wrapper around Strapi REST API, version 4. It has not been tested with previous versions.

**Strapi** is an open-source, Node.js based, Headless CMS to easily build customizable APIs.

I think it's one of the actual coolest solution for integrating a CMS into Rails for example, so let's dive in!

## Important Notice: Strapi V5 and strapi_ruby

Starting from version >=1.0.0, the StrapiRuby gem is only compatible with Strapi version 5 and above. This update includes significant changes to align with the new response format introduced in Strapi v5. Key changes include:

- **Flattened Response Format**: The `attributes` object has been removed, and fields are now directly part of the `data` object.
- **ID Handling**: The `id` field has been replaced with `documentId` to uniquely identify resources.
- **Filter Adjustments**: Filters that previously used `id` should now use `documentId`.

These changes ensure that the StrapiRuby gem takes full advantage of the improvements in Strapi v5, providing a more streamlined and efficient API interaction experience. Please ensure your Strapi server is updated to version 5 or later to use this version of the gem.

## Table of contents

- [Installation](#installation)
- Usage:
  - [API](#api):
    - [.get](#get)
    - [.post](#post)
    - [.put](#put)
    - [.delete](#delete)
    - [.escape_empty_answer](#escape_empty_answer)
  - [Basic Example: Rails](#basic-example-rails)
  - [Strapi Parameters](#strapi-parameters):
    - [populate](#populate)
    - [fields](#fields)
    - [sort](#sort)
    - [filters](#filters)
    - [page, page_size](#pagination-by-page-page--page_size)
    - [start, limit](#pagination-by-offset-start--limit)
    - [locale](#locale)
    - [publication_state](#publication_state)
  - [Use raw query](#use-raw-query)
- [Configuration](#configuration):
  - [DateTime conversion](#datetime-conversion)
  - [Markdown conversion](#markdown-conversion)
  - [Faraday block](#faraday-block)
- [Handling Errors](#handling-errors)
  - [Errors Classes](#errors-classes)
  - [Graceful degradation](#graceful-degradation)
- [Contributing](#contributing)
- [Tests](#tests)

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile
    gem "strapi_ruby"
```



Then if you use Rails, run in your terminal to generate a config initializer. Otherwise copy paste and fill the config block.

```bash
bundle
rake strapi_ruby:config
```

```ruby
# config/initializer/strapi_ruby.rb

# Don't
StrapiRuby.configure do |config|
  config.strapi_server_uri = "http://localhost:1337/api"
  config.strapi_token = "YOUR_TOKEN"
end

# Do
StrapiRuby.configure do |config|
  config.strapi_server_uri = ENV["STRAPI_SERVER_URI"]
  config.strapi_token = ENV["STRAPI_SERVER_TOKEN"]
end
```

##### IMPORTANT

- Always store sensible values in environment variables or Rails credentials
- Don't forget the trailing `/api` in your uri and don't finish it with a trailing slash.

And you're ready to fetch some data!

```ruby
StrapiRuby.get(resource: :restaurants)
# => https://localhost:1337/api/restaurants
```

## Usage

### API

When passing most of the arguments and options, you can use either `Symbol` or `String` for single fields/items, and an `Array` of `Symbol` or `String`.

API methods will return an [OpenStruct](https://ruby-doc.org/stdlib-2.5.1/libdoc/ostruct/rdoc/OpenStruct.html) which is similar to a Hash but you can access keys with dot notation. All fields of the OpenStruct have been recursively converted to OpenStruct as well so it's easy to navigate, as seen below

```ruby
# These are similar
answer = StrapiRuby.get(resource: :articles)
answer = StrapiRuby.get(resource: "articles")

# Grab data or meta
data = answer.data
meta = answer.meta

# Access a specific attribute
answer = StrapiRuby.get(resource: :articles, document_id: "clkgylmcc000008lcdd868feh")
article = answer.data
title = article.attributes.title

# If an error occur, it will be raised to be rescued and displayed in the answer.
data = answer.data # => nil
meta = answer.meta # => nil
error = answer.error.message # => ErrorType:ErrorMessage
endpoint = answer.endpoint
# => "https://localhost:1337/api/restaurants?filters[title][$contains]=this+does+not+exists
```

#### .get

```ruby
# Display all items of a collection as an array
answer = StrapiRuby.get(resource: :restaurants)


# Get a specific element
StrapiRuby.get(resource: :restaurants, document_id: "clkgylmcc000008lcdd868feh")
```

#### .post

```ruby
# Create an item of a collection, return item created
StrapiRuby.post(resource: :articles,
                data: {title: "This is a brand article",
                       content: "created by a POST request"})

```

#### .put

```ruby
# Update a specific item, return item updated
StrapiRuby.put(resource: :articles,
               document_id: "clkgylmcc000008lcdd868feh",
               data: {content: "'I've edited this article via a PUT request'"})
```

#### .delete

```ruby
# Delete an item, return item deleted
StrapiRuby.delete(resource: :articles, document_id: "clkgylmcc000008lcdd868feh")

```

#### .escape_empty_answer

See [`Graceful degradation`](#graceful-degradation)

### Basic Example: Rails

```ruby
# pages_controller.rb

def home
@articles = StrapiRuby.get(resource: :articles)
end
```

```erb
# home.html.erb

<% StrapiRuby.escape_empty_answer(@articles) do %>
  <ul>
    <% @articles.data.each do |article| %>
      <li>
        <%= article.attributes.title %>
      </li>
    <% end %>
  </ul>
<% end %>
```

### Strapi Parameters

`strapi_ruby`` API functions wraps all parameters offered by the Strapi REST Api V4.

The query is built using a transverse hash function similar to Javascript `qs` library used by Strapi.

Instead parameters should be passed as a hash to their key and you can use symbols instead of strings.

Only exceptions are for the `operators` of the filters used as keys. Also, Integers, eg. for ID, must be passed as strings.

Full parameters documentation from Strapi is available [here](https://docs.strapi.io/dev-docs/api/rest/parameters).

You can also use their interactive query builder. Just remember to convert the result correctly the resulting JS object to a hash with correct keys and values.

#### populate

```ruby
# Populate one level deep all relations
StrapiRuby.get(resource: :articles, populate: :*)
# => /articles?populate=*

# --------------------------------

# Populate one level deep a specific field
StrapiRuby.get(resource: :articles, populate: [:categories])
# => /articles?populate[0]=categories

# --------------------------------

# Populate two level deep
StrapiRuby.get(resource: :articles, populate: { author: { populate: [:company] } })
# => /articles??populate[author][populate][0]=company

# --------------------------------

# Populate a 2-level component and its media
StrapiRuby.get(resource: :articles, populate: [
                 "seoData",
                 "seoData.sharedImage",
                 "seoData.sharedImage.media",
               ])
# => articles?populate[0]=seoData&populate[1]=seoData.sharedImage&populate[2]=seoData.sharedImage.media

# --------------------------------

# Deeply populate a dynamic zone with 2 components
StrapiRuby.get(resource: :articles, populate: {
                 testDZ: {
                   populate: :*,
                 },
               })
# => /articles?populate[testDZ][populate]=*

# Using detailed population strategy
StrapiRuby.get(resource: :articles, populate: {
                 testDz: {
                   on: {
                     "test.test-compo" => {
                       fields: [:testString],
                       populate: :*,
                     },
                     "test.test-compo2" => {
                       fields: [:testInt],
                     },
                   },
                 },
               })
# => /articles?populate[testDz][on][test.test-compo][fields][0]=testString&populate[testDz][on][test.test-compo][populate]=*&populate[testDz][on][test.test-compo2][fields][0]=testInt
```

#### fields

```ruby
# Select one field
StrapiRuby.get(resource: :articles, fields: :title)
# => /articles?fields[0]=title

# --------------------------------

# Select multiple fields
StrapiRuby.get(resource: :articles, fields: [:title, :body])
# => /articles?fields[0]=title&fields[1]=body
```

#### sort

```ruby
# Sort by a single key
StrapiRuby.get(resource: :articles, sort: [])
# => articles?sort[0]=title&sort[1]=slug

# --------------------------------

# You can pass sort order and also sort by multiple keys
StrapiRuby.get(resource: :articles, sort: ["createdAt:desc", "title:asc"])
# => articles?sort[0]=created:desc&sort[1]=title:asc
```

#### filters

**Use a `String` and not a `Symbol` when using `operator`.**

| Operator        | Description                         |
| --------------- | ----------------------------------- |
| `$eq`           | Equal                               |
| `$eqi`          | Equal (case-insensitive)            |
| `$ne`           | Not Equal                           |
| `$nei`          | Not Equal (case-insensitive)        |
| `$lt`           | Less than                           |
| `$lte`          | Less than (case-insensitive)        |
| `$gt`           | Greater than                        |
| `$gte`          | Greater than (case-insensitive)     |
| `$in`           | In                                  |
| `$notIn`        | Not in                              |
| `$contains`     | Contains                            |
| `$notContains`  | Does not contain                    |
| `$containsi`    | Contains (case-insensitive)         |
| `$notContainsi` | Does not contain (case-insensitive) |
| `$null`         | Is null                             |
| `$notNull`      | Is not Null                         |
| `$between`      | Is between                          |
| `$startsWith`   | Starts with                         |
| `$startsWithi`  | Starts with (case-insensitive)      |
| `$endsWith`     | Ends with                           |
| `$endsWithi`    | Ends with (case-insensitive)        |
| `$or`           | Or                                  |
| `$and`          | And                                 |
| `$not`          | Not                                 |

---

```ruby
# Simple usage
StrapiRuby.get(resource: :users, filters: { username: { "$eq" => "John" } })
# => /users?filters[username][$eq]=John

# --------------------------------

# Using $in operator to match multiples values
StrapiRuby.get(resource: :restaurants,
               filters: {
                 documentId: {
                   "$in" => ["clkgylmcc000008lcdd868feh", "clkgylw7d000108lc4rw1bb6s"],
                 },
               })
# => /restaurants?filters[documentId][$in][0]=clkgylmcc000008lcdd868feh&filters[documentId][$in][0]=clkgylw7d000108lc4rw1bb6s

# --------------------------------

# Complex filtering with $and and $or
StrapiRuby.get(resource: :books,
               filters: {
                 "$or" => [
                   {
                     date: {
                       "$eq" => "2020-01-01",
                     },
                   },
                   {
                     date: {
                       "$eq" => "2020-01-02",
                     },
                   },
                 ],
                 author: {
                   name: {
                     "$eq" => "Kai doe",
                   },
                 },
               })
# => /books?filters[$or][0][date][$eq]=2020-01-01&filters[$or][1][date][$eq]=2020-01-02&filters[author][name][$eq]=Kai%20doe

# --------------------------------

# Deep filtering on relation's fields
StrapiRuby.get(resource: :restaurants,
               filters: {
                 chef: {
                   restaurants: {
                     stars: {
                       "$eq" => 5,
                     },
                   },
                 },
               })
# => /restaurants?filters[chef][restaurants][stars][$eq]=5
```

#### Pagination by page: page & page_size

Only one pagination method is possible.

```ruby
StrapiRuby.get(resource: :articles, page: 1, page_size: 10)
# => /articles?pagination[page]=1&pagination[pageSize]=10
```

#### Pagination by offset: start & limit

Only one pagination method is possible.

```ruby
StrapiRuby.get(resource: :articles, start: 0, limit: 10)
# => /articles?pagination[start]=0&pagination[limit]=10
```

#### locale

I18n plugin should be installed.

```ruby
StrapiRuby.get(resource: :articles, locale: :fr)
#=>?/articles?locale=fr
```

#### publication_state

Use `:preview` or `:live`

```ruby
StrapiRuby.get(resource: :articles, publication_state: :preview)
#=>?/articles?publicationState=preview
```

### Use raw query

If you wanna pass a raw query you decide to build, just use raw as an option.
It cannot be combined with any other Strapi parameters.

```ruby
StrapiRuby.get(resource: articles:, raw: "?fields=title&sort=createdAt:desc")
# => /articles?fields=title&sort=createdAt:desc"
```

## Configuration

You can pass more options via the config block.

### Show Endpoint

This option is for accessing the resulting endpoint in a **successful** error, ie. `strapi_server_uri` + its query.

It defaults to `false`.

```ruby
# Pass this as a parameter to the config block
StrapiRuby.configure do |config|
    #...
    config.show_endpoint = true
    #...
  end

# Or as an option to one of the API functions
StrapiRuby.get(resource: :articles, show_endpoint: true)


# You can access it in the answer

StrapiRuby.get(resource: :articles, show_endpoint: true).endpoint
# => https://localhost:1337/api/restaurants
```

Or directly in the options parameters

### DateTime Conversion

By default, any `createdAt`, `publishedAt` and `updatedAt` fields in the answer will be recursively converted to `DateTime` instances, making it easy to use [`#strftime`](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/DateTime.html#method-i-strftime) method.

But if you don't want this conversion, pass it to the configure block.

```ruby
StrapiRuby.configure do |config|
    #...
    config.convert_to_datetime = false
    #...
  end
```

### Markdown Conversion

Selected fields will automatically be converted to HTML using `redcarpet` gem. This is very useful to get data ready for the views.

```ruby
# You can pass this in your config file:

StrapiRuby.configure do |config|
    #...
    config.convert_to_html = [:body]
    #...
  end

# Or as an option to one of the API functions
StrapiRuby.get(resource: :articles, fields: :body, convert_to_html: [:body])
```

### Faraday Block

#### Passing a Proc

You can pass a proc when configuring Strapi Ruby just as you'd pass a block when creating a new instance of a Faraday.
Check [Faraday documentation](https://lostisland.github.io/faraday/#/customization/connection-options)

```ruby
StrapiRuby.configure do |config|
    #...
    config.faraday = Proc.new do |faraday|
       faraday.headers['X-Custom-Header'] = 'Custom-Value'
    end
    #...
  end
```

#### Default Faraday::Connection used by the gem

Default options used by this gem are `url_encode` and `Faraday.default_adapter`, but you can override them.

#### Default Faraday::Connection headers

Default headers cannot be overriden but will be merged with your added configuration.

```ruby
default_headers = { "Content-Type" => "application/json",
                    "Authorization" => "Bearer #{strapi_token}",
                    "User-Agent" => "StrapiRuby/#{StrapiRuby::VERSION}" }
```

### Handling Errors

Depending on your utilisation, there are multiple ways to handle errors.

#### Errors Classes

```ruby
# Config Error
class ConfigurationError < StandardError

# Client Error
class ClientError < StandardError

# Client Error Specific Error
class ConnectionError < ClientError
class UnauthorizedError < ClientError
class ForbiddenError < ClientError
class NotFoundError < ClientError
class UnprocessableEntityError < ClientError
class ServerError < ClientError
class BadRequestError < ClientError
class JSONParsingError < ClientError
```

#### Graceful degradation

One way to handle errors and gracefuly degrade is using `.escape_empty_answer` and use a block to nest your data accessing code.

Errors will still be logged in red in console.

##### Definition

```ruby
# Definition
module StrapiRuby
  def escape_empty_answer(answer)
    return answer.error.message if answer.data.nil?
    yield
  end
end
```

##### Example : Usage in a Rails view

```erb
<% StrapiRuby.escape_empty_answer(answer) do %>
  <%= answer.title %>
  <%= answer.body %>
<% end %>
```

Or you may want to handle specific errors like this:

```ruby
# some_controller.rb
begin
  answer = StrapiRuby.get(resource: "articles")
rescue NotFoundError e =>
  # Do something to avoid an embarassing situation
rescue ClientError e =>
  # Do something to avoid an embarassing situation
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at [https://github.com/saint-james-fr/strapi_ruby](https://github.com/saint-james-fr/strapi_ruby). This project is intended to be a safe, welcoming space for collaboration.

## Tests

Run `bundle exec rspec` to run the tests.

Inside `spec/integration.rb` you'll have access to integration tests.
You'll need to configure environment variables within the repo and run a strapi server to run these tests sucessfully.
See Strapi documentation for more details about installing a Strapi Server [here](https://docs.strapi.io/dev-docs/quick-start)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
