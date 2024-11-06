require 'firecrawl'
require 'debug'

request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::CrawlOptions.build do 
  maximum_depth         2
  limit                 4 
  scrape_options        do 
    format              [ :markdown, :screenshot ]
    only_main_content   true
  end
end

response = request.crawl( ARGV[ 0 ] || 'https://www.iana.org', options )
while response.success?
  crawl_result = response.result 
  crawl_result.scrape_results.each do | result |
    puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
    puts 'URL: ' + ( result.metadata[ 'source_url' ] || '' )
    puts 'Screenshot: ' + result.screenshot_url
    puts '---'
    puts result.markdown
    puts "\n\n"
  end 
  break unless crawl_result.status?( :scraping ) 
  sleep 0.500
  response = request.retrieve_crawl_results( crawl_result )
end 

unless response.success?
  puts response.result.error_description 
end 
