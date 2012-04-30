require 'rubygems'
require 'json'
require 'net/http'

require 'ipaddr'

IP_FACTS = ['ipaddress', 'ipaddress_eth0', 'ipaddress_eth1', 'ec2_public_ipv4']

# Snippet from http://snippets.dzone.com/posts/show/8607
class IPAddr
  PrivateRanges = [
    IPAddr.new("10.0.0.0/8"),
    IPAddr.new("172.16.0.0/12"),
    IPAddr.new("192.168.0.0/16")
  ]
  
  def private?
    return false unless self.ipv4?
    PrivateRanges.each do |ipr|
      return true if ipr.include?(self)
    end
    return false
  end

  def public?
    !private?
  end
end

def ip_search()
   for ip_fact in IP_FACTS
     ip = Facter.value(ip_fact)
     if ip && IPAddr.new(ip).public?
       break
     end
   end
   data_file = "/var/lib/puppet/state/fact_geoloc.json" # TODO: Use IP as parameter, so it instantly changes
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
   return data
end

Facter.add("country") do
    setcode do
      ip_search["country"]
    end
end