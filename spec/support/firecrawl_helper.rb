module FirecrawlHelper
  def connection 
    Faraday.new do | builder | 
      builder.adapter Faraday.default_adapter 
      builder.use VCR::Middleware::Faraday 
    end
  end
end

RSpec.configure do | config |
  config.include FirecrawlHelper
end
