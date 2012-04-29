require 'rubygems'
require 'json'
require 'net/http'

def ip_search()
   ip = Facter.value('ipaddress')
   data_file = "/var/lib/puppet/state/fact_geoloc.json"
   if File.exists?(data_file):
     data = JSON.parse(File.open(data_file).read)
   else
     url = "http://stat.ripe.net/plugin/geoloc/data.json?resource=#{ip}"
     resp = Net::HTTP.get_response(URI.parse(url))
     result = JSON.parse(resp.body)
     data = result['data']['locations'].first
     dest = File.new(data_file, 'w+')
     dest.puts(data.to_json)
   end
   return 
end

Facter.add("country") do
    setcode do
      return ip_search["country"]
    end
end