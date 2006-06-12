#!/usr/bin/env ruby

# load HTTP request class and REXML Document class
require 'net/http'
require 'rexml/document'

# set the username to fetch
username = 'othiym23'

# the URL for the most recent weekly chart
weekly_feed_url = "http://ws.audioscrobbler.com/1.0/user/#{username}/recenttracks.xml"

# load the feed
weekly_feed = Net::HTTP.get_response(URI.parse(weekly_feed_url))

# create a new REXML Document
document = REXML::Document.new(weekly_feed.body)

# use an XPath to find all the artists in the chart and print a list of their number of plays
document.root.get_elements('//track').slice(0, 10).each do |track|
  puts track.elements['artist'].children.to_s + ': ' + track.elements['name'].children.to_s
end