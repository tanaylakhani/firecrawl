# Firecrawl

Firecrawl is a lightweight Ruby gem that provides a semantically straightfoward interface to 
the Firecrawl.dev API, allowing you to easily scrape web content, take screenshots, as well as 
crawl entire web domains. 

The gem is particularly useful when working with Large Language Models (LLMs) as it can 
provide markdown information for real time information lookup as well as grounding.

```ruby
require 'firecrawl'

Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]
response = Firecrawl.scrape( 'https://example.com' )
if response.success?
  result = response.result 
  puts result.metadata[ 'title' ]
  puts '---'
  puts result.markdown
  puts "Screenshot URL: #{ result.screenshot_url }"
else 
  puts response.result.error_description 
end 
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firecrawl'
```

Then execute:

```bash
$ bundle install
```

Or install it directly:

```bash
$ gem install firecrawl
```

## Usage

### Scraping

The simplest way to use Firecrawl is to `scrape`, which will scrape the content of a single page
at the given url and optionally convert it to markdown as well as create a screenshot. You can 
chose to scrape the entire page or only the main content.

```ruby
Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]
response = Firecrawl.scrape( 'https://example.com', format: :markdown )

if response.success?
  result = response.result
  if result.success?
    puts result.metadata[ 'title' ]
    puts result.markdown
  end
else
  puts response.result.error_description
end
```

In this basic example we have globally set the `Firecrawl.api_key` from the environment and then
used the `Firecrawl.scrape` convenience method to make a request to the Firecrawl API to scrape 
the `https://example.com` page and return markdown ( markdown and the main content of the page 
are returned by default so we could have ommitted the options entirelly ).

The `Firecrawl.scrape` method instantiates a `Firecrawl::ScrapeRequest` instance and then calls
it's `submit` method. The following is the equivalent code which makes explict use of the 
`Firecrawl::ScrapeRequest` class.

```ruby
request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com', format: :markdown )

if response.success?
  result = response.result
  if result.success?
    puts result.metadata[ 'title' ]
    puts result.markdown
  end
else
  puts response.result.error_description
end
```

Notice also that in this example we've directly passed the `api_key` to the individual request. 
This is optional. If you set the key globally and omit it in the request constructor the 
`ScrapeRequest` instance will use the globally assigned `api_key`.

#### Scrape Options

You can customize scraping behavior using options, either by passing an option hash to 
`submit` method, as we have done above, or by building a `ScrapeOptions` instance:

```ruby
options = Firecrawl::ScrapeOptions.build do 
  formats           [ :html, :markdown, :screenshot ]
  only_main_content true
  include_tags      [ 'article', 'main' ]
  exclude_tags      [ 'nav', 'footer' ]
  wait_for          5000  # milliseconds
end

request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.submit( 'https://example.com', options )
```

#### Scrape Response

The `Firecrawl` gem is based on the `Faraday` gem, which permits you to customize the request
orchestration, up to and including changing the actual HTTP implementation used to make the 
request. See Connections below for additional details.

Any `Firecrawl` request, including the `submit` method as used above, will thus return a 
`Faraday::Response`. This response includes a `success?` method which indicates if the request 
was successful. If the request was successful, the `response.result` method will be an instance 
of `Firecrawl::ScrapeResult` that will encapsulate the scraping result. This instance, in turn, 
has a `success?` method which will return `true` if Firecrawl successfully scraped the page. 

A successful result will include html, markdown, screenshot, as well as any action and llm 
results and related metadata. 

If the response is not successful ( if `response.success?` is `false` ) then `response.result` 
will be an instance of Firecrawl::ErrorResult which will provide additional details about the 
nature of the failure.

### Batch Scraping

For scraping multiple URLs efficiently:

```ruby
request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

urls = [ 'https://example.com', 'https://example.org' ]
options = Firecrawl::ScrapeOptions.build do 
  format :markdown
  only_main_content true
end

response = request.submit( urls, options )
while response.success?
  batch_result = response.result
  batch_result.scrape_results.each do |result|
    puts result.metadata['title']
    puts result.markdown
    puts "\n---\n"
  end
  break unless batch_result.status?( :scraping )
  sleep 0.5
  response = request.retrieve( batch_result )
end
```

### Site Mapping

To retrieve a site's structure:

```ruby
request = Firecrawl::MapRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::MapOptions.build do 
  limit 100
  ignore_subdomains true
end

response = request.submit( 'https://example.com', options )
if response.success?
  result = response.result
  result.links.each do |link|
    puts link
  end
end
```

### Site Crawling

For comprehensive site crawling:

```ruby
request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::CrawlOptions.build do 
  maximum_depth 2
  limit 10
  scrape_options do 
    format :markdown
    only_main_content true
  end
end

response = request.submit( 'https://example.com', options )
while response.success?
  crawl_result = response.result
  crawl_result.scrape_results.each do | result |
    puts result.metadata[ 'title' ]
    puts result.markdown
  end
  break unless crawl_result.status?( :scraping )
  sleep 0.5
  response = request.retrieve( crawl_result )
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
