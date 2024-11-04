module Firecrawl 
  class BatchScrapeResult 

    def initialize( success, attributes )
      @success = success
      @attributes = attributes || {}
    end

    def success?
      @success || false 
    end

    def status
      # the initial Firecrawl response does not have a status so we synthesize a 'scraping'
      # status if the operation was otherwise successful 
      @attributes[ :status ]&.to_sym || ( @success ? :scraping : :failed )
    end 

    def status?( status )
      self.status == status 
    end 

    def id
      @attributes[ :id ]
    end

    def total 
      @attributes[ :total ] || 0
    end

    def completed
      @attributes[ :completed ] || 0
    end 

    def credits_used 
      @attributes[ :creditsUsed ] || 0
    end 

    def expires_at
      Date.parse( @attributes[ :expiresAt ] ) rescue nil
    end

    def url 
      @attributes[ :url ] 
    end 
    
    def next_url 
      @attributes[ :next ] || @attributes[ :url ] 
    end 

    def scrape_results 
      success = @attributes[ :success ]
      # note the &.compact is here because I've noted null entries in the data
      ( @attributes[ :data ]&.compact || [] ).map do | attr |
        ScrapeResult.new( success, attr )
      end
    end 

    def merge( attributes )
      self.class.new( attributes[ :success ], @attributes.merge( attributes ) )
    end 
  end
end
