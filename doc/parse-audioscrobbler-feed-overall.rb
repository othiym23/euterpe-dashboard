#!/usr/bin/env ruby

# load HTTP request class and REXML Document class
require 'net/http'
require 'rexml/document'

# set the username to fetch
username = 'othiym23'

# the URL for the most recent weekly chart
overall_url = "http://ws.audioscrobbler.com/1.0/user/#{username}/topartists.xml"

# load the feed
overall = Net::HTTP.get_response(URI.parse(overall_url))

# create a new REXML Document
document = REXML::Document.new(overall.body)

# use an XPath to find all the artists in the chart and print a list of their number of plays
document.root.get_elements('//artist').sort { |a,b| a.elements['playcount'].children.to_s.to_i <=> b.elements['playcount'].children.to_s.to_i }.reverse.slice(0, 10).each do |artist|
  puts '# ' + artist.elements['name'].children.to_s + ' (' + artist.elements['playcount'].children.to_s + ' listens)'
end