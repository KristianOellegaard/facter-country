require 'rubygems'
require 'json'
require 'net/http'

def ip_search(ip)
   url = "http://stat.ripe.net/plugin/geoloc/data.json?resource=#{ip}"
   resp = Net::HTTP.get_response(URI.parse(url))
   result = JSON.parse(resp.body)
   return result['data']['locations'].first
end

Facter.add("country", :ttl => 2629743) do # One month TTL
    setcode do
      ip_search(Facter.value('ipaddress'))["country"]
    end
end