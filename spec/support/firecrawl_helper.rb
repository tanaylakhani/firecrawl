module FirecrawlHelper
  
  def connection 
    Faraday.new do | builder | 
      builder.adapter Faraday.default_adapter 
      builder.use VCR::Middleware::Faraday 
    end
  end

  def response_error_description( response )
    ( response&.result&.respond_to?( :error_description ) ? response.result.error_description : nil ) || ''
  end

end

RSpec.configure do | config |
  config.include FirecrawlHelper
end
