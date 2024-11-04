module Firecrawl
  #
  # The ResponseMethods module extends a Faraday reponse, adding the +result+ method. 
  #
  module ResponseMethods
    def self.install( response, result )
      response.instance_variable_set( "@_firecrawl_result", result )
      response.extend( ResponseMethods )    
    end 

    def result
      @_firecrawl_result
    end 
  end
end 
