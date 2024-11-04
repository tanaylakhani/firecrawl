module Firecrawl
  class CrawlOptions 
    include DynamicSchema::Definable 
    include DynamicSchema::Buildable

    FORMATS = [ :markdown, :links, :html, :raw_html, :screenshot ]

    ACTIONS = [ :wait, :click, :write, :press, :screenshot, :scrape ]

    schema do 
      exclude_paths         String, as: :excludePaths, array: true
      include_paths         String, as: :includePaths, array: true
      maximum_depth         Integer, as: :maxDepth 
      ignore_sitemap        [ TrueClass, FalseClass ], as: :ignoreSitemap 
      limit                 Integer 
      allow_backward_links  [ TrueClass, FalseClass ], as: :allowBackwardLinks
      allow_external_links  [ TrueClass, FalseClass ], as: :allowExternalLinks
      webhook               String 
      scrape_options        as: :scrapeOptions, &ScrapeOptions.schema
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end 

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end 

    def initialize( options, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options 
      
      scrape_options = @options[ :scrapeOptions ]
      if scrape_options 
        scrape_options[ :formats ]&.map!( &method( :string_camelize ) )
      end 
    end

    def to_h
      @options.to_h 
    end

  end
end


