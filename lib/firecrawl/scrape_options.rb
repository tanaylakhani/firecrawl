module Firecrawl
  class ScrapeOptions 
    include DynamicSchema::Definable 
    include Helpers

    FORMATS = [ :markdown, :links, :html, :raw_html, :screenshot, :"screenshot@full_page" ]

    ACTIONS = [ :wait, :click, :write, :press, :screenshot, :scrape ]

    schema do 
      # note: both format and formats are defined as a semantic convenience
      format            String, as: :formats, array: true, in: FORMATS
      formats           String, array: true, in: FORMATS 
      only_main_content [ TrueClass, FalseClass ], as: :onlyMainContent 
      include_tags      String, as: :includeTags, array: true 
      exclude_tags      String, as: :excludeTags, array: true 
      wait_for          Integer 
      timeout           Integer 
      extract           do 
        schema          Hash
        system_prompt   String, as: :systemPrompt
        prompt          String
      end 
      action            as: :actions, arguments: :type, array: true do 
        type            Symbol, required: true, in: ACTIONS        
        # wait  
        milliseconds    Integer 
        # click 
        selector        String 
        # write 
        text            String 
        # press
        key             String 
      end 
    end

    def self.build( options = nil, &block )
      new( api_options: builder.build( options, &block ) )
    end 

    def self.build!( options = nil, &block )
      new( api_options: builder.build!( options, &block ) )
    end 

    def initialize( options = {}, api_options: nil )
      @options = self.class.builder.build( options || {} )
      @options = api_options.merge( @options ) if api_options 
      @options[ :formats ]&.map! { | format | string_camelize( format.to_s ) }
    end

    def to_h
      @options.to_h 
    end

  end
end


