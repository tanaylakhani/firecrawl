module Firecrawl
  class CrawlOptions 
    include DynamicSchema::Definable 
    include Helpers

    schema do 
      exclude_paths         String, as: :excludePaths, array: true
      include_paths         String, as: :includePaths, array: true
      maximum_depth         Integer, as: :maxDepth 
      ignore_sitemap        [ TrueClass, FalseClass ], as: :ignoreSitemap 
      limit                 Integer, in: (0..)
      allow_backward_links  [ TrueClass, FalseClass ], as: :allowBackwardLinks
      allow_external_links  [ TrueClass, FalseClass ], as: :allowExternalLinks
      webhook_uri           URI, as: :webhook 
      scrape_options        as: :scrapeOptions, &ScrapeOptions.schema
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end 

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end 

    def initialize( options = nil, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options 
      
      scrape_options = @options[ :scrapeOptions ]
      if scrape_options 
        scrape_options[ :formats ]&.map! { | format | string_camelize( format.to_s ) }
      end 
    end

    def to_h
      @options.to_h 
    end

  end
end


