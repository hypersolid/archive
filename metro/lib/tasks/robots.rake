require 'net/http'
require 'uri'

namespace :robots  do
  task :parse => :environment do
    uri = URI.parse("http://api.sheepla.com/")

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    
    request.content_type = "text/xml"
    request.body = open('public/order.xml').read()
    
    response = http.request(request)
    
    p response.code 
    p response.body
        
  end
end