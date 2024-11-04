require_relative '../lib/firecrawl'

request = Firecrawl::ScrapeRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' ] )

options = Firecrawl::ScrapeOptions.build do 
  format                [ :markdown, 'screenshot@full_page' ]
  only_main_content     true
end

response = request.scrape( ARGV[ 0 ] || 'https://example.com', options )
if response.success?
  result = response.result 
  puts 'Title: ' + ( result.metadata[ 'title' ] || '' )
  puts 'Screenshot: ' + result.screenshot_url
  puts '---'
  puts result.markdown
else 
  puts response.result.error_description 
end 

