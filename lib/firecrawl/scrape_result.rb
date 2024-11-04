module Firecrawl 
  class ScrapeResult 

    def initialize( success, attributes )
      @success = success 
      @attributes = attributes || {}
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
    # The +markdown+ method returns scraped content that has been converted to markdown. The 
    # markdown content is present only if the request options +formats+ included +markdown+.  
    #
    def markdown
      @attributes[ :markdown ]
    end 

    ##
    # The +html+ method returns scraped html content. The html content is present only if the 
    # request options +formats+ included +html+.  
    #
    def html 
      @attributes[ :html ] 
    end 

    ##
    # The +raw_html+ method returns the full scraped html content of the page. The raw html 
    # content is present only if the request options +formats+ included +raw_html+.  
    #
    def raw_html
      @attributes[ :rawHtml ]
    end 

    ##
    # The +screenshot_url+ method returns the url of the screenshot of the requested page. The 
    # screenshot url is present only if the request options +formats+ included +screenshot+ or 
    # +screenshot@full_page+.
    #
    def screenshot_url
      @attributes[ :screenshot ]
    end 

    ##
    # The +links+ method returns an array of the links that were scraped from the the page. 
    # The +links+ are empty unless the request options +formats+ included +links+.
    #
    def links 
      @attributes[ :links ] || [] 
    end 

    ##
    # The +actions+ method returns an object of action results ( +scrapes+ or +screenshots+ ).  
    # The +actions+ are empty unless the request options included +scrape+ or +scresshot+ 
    # actions.
    #
    def actions 
      @attributes[ :actions ] || {}
    end

    def metadata 
      unless @metadata 
        metadata = @attributes[ :metadata ] || {}
        @metadata = metadata.transform_keys do | key |
          key.to_s.gsub( /([a-z])([A-Z])/, '\1_\2' ).downcase
        end
        # remove the camelCase forms injected by Firecrawl
        @metadata.delete_if do | key, _ | 
          key.start_with?( 'og_' ) && @metadata.key?( key.sub( 'og_', 'og:' ) )
        end 
      end 
      @metadata 
    end

    def llm_extraction 
      @attributes[ :llm_extraction ] || {}
    end

    def warning 
      @attributes[ :warning ] 
    end

  end
end
