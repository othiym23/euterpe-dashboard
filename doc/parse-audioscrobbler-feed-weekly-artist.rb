#!/usr/bin/env ruby

# load HTTP request class and REXML Document class
require 'net/http'
require 'rexml/document'

# set the username to fetch
username = 'othiym23'

# the URL for the most recent weekly chart
weekly_feed_url = "http://ws.audioscrobbler.com/1.0/user/#{username}/weeklyartistchart.xml"

# load the feed
weekly_feed = Net::HTTP.get_response(URI.parse(weekly_feed_url))

# create a new REXML Document
document = REXML::Document.new(weekly_feed.body)

# use an XPath to find the first 10 artists (ignoring ranking) in the chart
document.root.get_elements('//artist').slice(0, 10).each do |artist|
  # print a list of each artist's number of plays
  puts '# ' + artist.elements['name'].children.to_s + ' (' + artist.elements['playcount'].children.to_s + ' listens)'
end