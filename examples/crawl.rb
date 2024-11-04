require 'firecrawl'

request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )

options = Firecrawl::CrawlOptions.build do 
  maximum_depth         5
  scrape_options        do 
    format              [ :markdown, :screenshot ]
    only_main_content   true
  end
end

response = request.begin_crawl( 'https://example.com', options )

if response.success?
  result = response.result 
  loop 
    response = result.crawl
    break unless response.success?
    result = response.result 
    result.each do | scrape_result |
      puts scrape_result.metadata[ :title ]
      puts scrape_result.markdown 
      puts '---'
    end
    break if result.completed?
  end 
end 

unless response.success?
  puts response.result.error_description 
end 
