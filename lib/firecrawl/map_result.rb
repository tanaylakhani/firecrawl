module Firecrawl 
  class MapResult 

    def initialize( success, attributes )
      @success = success
      @attributes = attributes
    end

    ##
    # The +success?+ method returns +true+ if the scraping was successful. 
    #
    # Note that the response +success?+ tells you if the call to the Firecrawl api was successful 
    # while this +success?+ method tells you if the actual scraping operation was successful.
    #
    def success?  
      @success || false 
    end 

    ##
    # The +links+ method returns an array of the links that were scraped from the the page. 
    # The +links+ are empty unless the request options +formats+ included +links+.
    #
    def links 
      @attributes[ :links ] || [] 
    end 

  end
end

