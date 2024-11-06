module Firecrawl 

  ##
  # The +CrawlRequest+ class encapsulates a crawl request to the Firecrawl API. After creating 
  # a new +CrawlRequest+ instance you can begin crawling by calling the +crawl+ method and 
  # then subsequently retrieving the results by calling the +retrieve_crawl_results+ method.
  # You can also optionally cancel the crawling operation by calling +cancel_crawl+.
  #
  # === examples
  # 
  # require 'firecrawl'
  #
  # request = Firecrawl::CrawlRequest.new( api_key: ENV[ 'FIRECRAWL_API_KEY' )
  #
  # urls = 'https://icann.org'
  # options = Firecrawl::CrawlOptions.build do 
  #   scrape_options        do 
  #     main_content_only   true 
  #   end 
  # end
  # 
  # crawl_response = request.crawl( urls, options )
  # while crawl_response.success?
  #   crawl_result = crawl_response.result 
  #   if crawl_result.success?
  #     crawl_result.scrape_results.each do | result |
  #       puts response.metadata[ 'title ] 
  #       puts '---'
  #       puts response.markdown
  #       puts "\n\n"
  #     end
  #   end
  #   break unless crawl_result.status?( :scraping )
  #   crawl_response = request.
  # end
  #
  # unless crawl_response.success? 
  #   puts crawl_response.result.error_description 
  # end 
  # 
  class CrawlRequest < Request 

    ## 
    # The +crawl+ method makes a Firecrawl '/crawl' POST request which will initiate crawling 
    # of the given url. 
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is true,
    # then +response.result+ will be an instance +CrawlResult+. If the request is not successful 
    # then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validr that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def crawl( url, options = nil, &block )        
      if options
        options = options.is_a?( CrawlOptions ) ? options : CrawlOptions.build( options.to_h ) 
        options = options.to_h
      else 
        options = {}
      end
      options[ url ] = url
      response = post( "#{BASE_URI}/crawl", options, &block )
      result = nil 
      if response.success?
        attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )
        attributes ||= { success: false, status: :failed  }
        result = CrawlResult.new( attributes[ :success ], attributes )
      else 
        result = ErrorResult.new( response.status, attributes )
      end

      ResponseMethods.install( response, result )  
    end 

    ## 
    # The +retrieve_crawl_results+ method makes a Firecrawl '/crawl/{id}' GET request which 
    # will return the crawl results that were completed since the previous call to this method
    # ( or, if this is the first call to this method, since the crawl was started ). Note that 
    # there is no guarantee that there are any new crawl results at the time you make this call 
    # ( scrape_results may be empty ).
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is 
    # +true+, then +response.result+ will be an instance +CrawlResult+. If the request is not 
    # successful then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validate that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def retrieve_crawl_results( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )
      response = get( crawl_result.next_url, &block )  
      result = nil 
      if response.success? 
        attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )
        attributes ||= { success: false, status: :failed  }
        result = crawl_result.merge( attributes  )
      else 
        result = ErrorResult.new( response.status, attributes )
      end 

      ResponseMethods.install( response, result )     
    end

    ## 
    # The +cance_crawl+ method makes a Firecrawl '/crawl/{id}' DELETE request which will cancel 
    # a previouslly started crawl.
    # 
    # The response is always an instance of +Faraday::Response+. If +response.success?+ is 
    # +true+, then +response.result+ will be an instance +CrawlResult+. If the request is not 
    # successful then +response.result+ will be an instance of +ErrorResult+.
    #
    # Remember that you should call +response.success?+ to validate that the call to the API was
    # successful and then +response.result.success?+ to validate that the API processed the
    # request successfuly. 
    #
    def cancel_crawl( crawl_result, &block )
      raise ArgumentError, "The first argument must be an instance of CrawlResult." \
        unless crawl_result.is_a?( CrawlResult )
      response = get( crawl_result.url, &block )  
      result = nil 
      if response.success? 
        attributes = ( JSON.parse( response.body, symbolize_names: true ) rescue nil )
        attributes ||= { success: false, status: :failed  }
        result = crawl_result.merge( attributes  )
      else 
        result = ErrorResult.new( response.status, attributes )
      end 

      ResponseMethods.install( response, result )     
    end

  end 
end
