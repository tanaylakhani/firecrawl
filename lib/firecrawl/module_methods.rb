module Firecrawl
  module ModuleMethods
    DEFAULT_CONNECTION = Faraday.new { | builder | builder.adapter Faraday.default_adapter }
    
    def connection( connection = nil )
      @connection = connection || @connection || DEFAULT_CONNECTION    
    end

    def api_key( api_key = nil )
      @api_key = api_key || @api_key
      @api_key 
    end  

    def scrape( url, options = nil, &block )
      Firecrawl::ScrapeRequest.new.scrape( url, options, &block ) 
    end  
  end
end
