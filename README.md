# Firecrawl

Firecrawl is a lightweight Ruby gem that provides a semantically straightfoward interface to 
the Firecrawl.dev API, allowing you to easily scrape web content, take screenshots, as well as 
crawl entire web domains. 

The gem is particularly useful when working with Large Language Models (LLMs) as it can 
provide markdown information for real time information lookup as well as grounding.

```ruby
require 'firecrawl'

Firecrawl.api_key ENV[ 'FIRECRAWL_API_KEY' ]
response = Firecrawl.scrape( 'https://example.com', options )
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

### Basic Scraping

The simplest way to use Firecrawl is to scrape a single page:

```ruby
Firecrawl.api_key ENV['FIRECRAWL_API_KEY']
response = Firecrawl.scrape('https://example.com', format: :markdown )

if response.success?
  result = response.result
  if result.success?
    puts result.metadata['title']
    puts result.markdown
  end
else
  puts response.result.error_description
end
```

### Scrape Options

You can customize scraping behavior using `ScrapeOptions`:

```ruby
options = Firecrawl::ScrapeOptions.build do 
  formats           [ :html, :markdown, :screenshot ]
  only_main_content true
  include_tags      [ 'article', 'main' ]
  exclude_tags      [ 'nav', 'footer' ]
  wait_for          5000  # milliseconds
end

request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )
response = request.scrape('https://example.com', options)
```

### Batch Scraping

For scraping multiple URLs efficiently:

```ruby
request = Firecrawl::BatchScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

urls = [ 'https://example.com', 'https://example.org' ]
options = Firecrawl::ScrapeOptions.build do 
  format :markdown
  only_main_content true
end

response = request.scrape( urls, options )
while response.success?
  batch_result = response.result
  batch_result.scrape_results.each do |result|
    puts result.metadata['title']
    puts result.markdown
    puts "\n---\n"
  end
  break unless batch_result.status?( :scraping )
  sleep 0.5
  response = request.retrieve_scrape_results( batch_result )
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

response = request.map( 'https://example.com', options )
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

response = request.crawl( 'https://example.com', options )
while response.success?
  crawl_result = response.result
  crawl_result.scrape_results.each do |result|
    puts result.metadata['title']
    puts result.markdown
  end
  break unless crawl_result.status?(:scraping)
  sleep 0.5
  response = request.retrieve_crawl_results(crawl_result)
end
```

## Response Structure

All Firecrawl requests return a Faraday response with an added `result` method. The result will 
be one of:

- `ScrapeResult`: Contains the scraped content and metadata
- `BatchScrapeResult`: Contains multiple scrape results
- `MapResult`: Contains discovered links
- `CrawlResult`: Contains scrape results from crawled pages
- `ErrorResult`: Contains error information if the request failed

### Working with Results

```ruby
response = request.scrape(url, options)
if response.success?
  result = response.result
  if result.success?
    # Access scraped content
    puts result.metadata['title']
    puts result.markdown
    puts result.html
    puts result.raw_html
    puts result.screenshot_url
    puts result.links
    
    # Check for warnings
    puts result.warning if result.warning
  end
else
  error = response.result
  puts "#{error.error_type}: #{error.error_description}"
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
