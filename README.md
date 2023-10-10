# StrapiRuby

<div align="center">
<img src="assets/strapi_ruby_logo.png" width="150px">
</div>

**StrapiRuby** is a Ruby wrapper around Strapi REST API, version 4. It has not been tested with previous versions.

**Strapi** is an open-source, Node.js based, Headless CMS to easily build customizable APIs.

I think it's one of the actual coolest solution for integrating a CMS into Rails for example, so let's dive in!

## Table of contents

- [Installation](#installation)
- Usage:
  - [API](#api):
    - [get](#get)
    - [post](#post)
    - [put](#put)
    - [delete](#delete)
  - [Strapi Parameters](#strapi-parameters):
    - [populate](#populate)
    - [fields](#fields)
    - [sort](#sort)
    - [filters](#filters)
    - [page, page_size](#pagination-by-page-page--page_size)
    - [start, limit](#pagination-by-page-start--limit)
    - [locale](#locale)
    - [publication_state](#publication_state)
  - [Use raw query](#use-raw-query)
- [Configuration](#configuration):
  - [DateTime conversion](#datetime-conversion)
  - [Markdown conversion](#markdown-conversion)
  - [Faraday block](#faraday-block)
- [Contributing](#contributing)
- [Tests](#tests)

## Installation

Add this line to your application's Gemfile:

```ruby
# Gemfile

    gem "strapi_ruby"
```

Then if you use Rails, run in your terminal:

```bash
rake strapi_ruby:install
```

This will generate a config file for you. If you're not using Rails, copy paste the config code below before using the gem.

##### IMPORTANT

Don't forget the trailing `/api` in your uri and don't finish it with a trailing slash.

```ruby
# config/strapi_ruby.rb

StrapiRuby.configure do |config|
    config.strapi_server_uri = "http://localhost:1337/api"
    config.strapi_token = "YOUR_TOKEN"
  end
```

And you're ready to fetch some data!

```ruby
StrapiRuby.get(resource: :restaurants)
# => https://localhost:1337/api/restaurants
```

## Usage

### API

You can use either `Symbol` or `String` when passing most of the arguments.
API methods will return an OpenStruct which is a sort of Hash where you can access keys with dot notation.
The answer has been made available through `data`, `meta` and `error`.
All subsequent hashes have been also converted to OpenStruct. It's really easy to navigate!

```ruby
# Structure of the answers

# You can access your data like this
answer = StrapiRuby.get(resource: :articles)

# Grab data
data = answer.data

# Metadata for pagination for example
meta = answer.meta

# You access a specific attribute like this
answer = StrapiRuby.get(resource: :articles, id: 2)
article = answer.data
title = article.attributes.title

# If an error occur (400, 401, 403, 404, 422, 500..599), it will be raised and stop execution.
```

#### .get

```ruby
# Display all items of a collection, returns an array
answer = StrapiRuby.get(resource: :restaurants)


# Get a specific element
StrapiRuby.get(resource: :restaurants, id: 1)
```

#### .post

```ruby
# Creates an item of a collection, returns item created
StrapiRuby.post(resource: :articles,
                data: {title: "This is a brand article",
                       content: "created by a POST request"})

```

#### .put

```ruby
# Updates a specific item, returns item updated
StrapiRuby.put(resource: :articles,
               id: 23,
               data: {content: "'I've edited this article via a PUT request'"})
```

#### .delete

```ruby
# Deletes an item, returns item deleted
StrapiRuby.delete(resource: :articles, id: 12)

```

### Strapi Parameters

`strapi_ruby`` API functions wraps all parameters offered by the Strapi REST Api V4.

The query is built using a transverse hash function similar to Javascript `qs` library used by Strapi.

Instead parameters should be passed as a hash and you can use symbols instead of strings - except for the operators of the filters used as keys. Integers, eg. for ID, must be passed as strings.

Full parameters documentation from Strapi is available [here](https://docs.strapi.io/dev-docs/api/rest/parameters).

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
                 id: {
                   "$in" => ["3", "6", "8"],
                 },
               })
# => /restaurants?filters[id][$in][0]=3&filters[id][$in][1]=6&filters[id][$in][2]=8

# --------------------------------

# Complex filtering with $and and $or
RubyStrapi.get(resource: :books,
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
# => /articles?pagination[start]=0&pagination[limit]=12
```

#### locale

I18n plugin should be installed.

```ruby
StrapiRuby.get(resource: :articles, locale: :fr)
#=>?/articles?locale=fr
```

#### publication_state

Use `preview` or `live`

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

This option is for accessing the resulting endpoint, ie. `strapi_server_uri` and its query, it is useful for debugging. It defaults to `false`.

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

By default, any `createdAt`, `publishedAt` and `updatedAt` fields in the answer will be recursively converted to `DateTime` instances, making it easy to use `#strftime` method, you can consult its documentation [here](https://ruby-doc.org/stdlib-2.6.1/libdoc/date/rdoc/DateTime.html#method-i-strftime).

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

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saint-james-fr/strapi_ruby. This project is intended to be a safe, welcoming space for collaboration.

## Tests

Run `bundle exec rspec` to run the tests.

Inside `spec/integration.rb` you'll have access to integration tests.
You'll need to configure environment variables within the repo and run a strapi server to run these tests sucessfully.
See Strapi documentation for more details about installing a Strapi Server [here](https://docs.strapi.io/dev-docs/quick-start)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
