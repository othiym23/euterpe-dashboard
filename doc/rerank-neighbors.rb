#!/usr/bin/env ruby

# load HTTP request class and REXML Document class
require 'set'
require 'cgi'
require 'net/http'
require 'rexml/document'

my_name = 'othiym23'

def fetch_xml_document(url_string)
  # load the feed
  puts "xml: Loading document at #{url_string}"
  overall = Net::HTTP.get_response(URI.parse(url_string))

  # create a new REXML Document
  document = REXML::Document.new(overall.body)
end

def parse_ranked_artists(username)
  # the URL for the most recent weekly chart
  overall_url = "http://ws.audioscrobbler.com/1.0/user/#{CGI.escape(username)}/topartists.xml"

  # load the artist list
  document = fetch_xml_document(overall_url)

  # create a new artist array
  ranked_artists = Hash.new

  # use an XPath to find all the artists in the chart and print a list of their number of plays
  document.root.get_elements('//artist').each do |artist|
    ranked_artists[artist.elements['name'].children.to_s] = artist.elements['rank'].children.to_s.to_i
  end

  ranked_artists
end

def parse_fans( artist, neighbors )
  # the URL for the most recent weekly chart
  fan_url = "http://ws.audioscrobbler.com/1.0/artist/#{CGI.escape(artist)}/fans.xml"

  # load the fans
  document = fetch_xml_document(fan_url)

  # use an XPath to find all the artists in the chart and print a list of their number of plays
  document.root.get_elements('//user').each do |fan|
    fan_username = fan.attributes['username'].to_s
    if not neighbors[fan_username]
      puts "ngb: Processing fan #{fan_username}"
      neighbors[fan_username] = parse_ranked_artists(fan_username)
    end
  end
  
  neighbors
end

def parse_neighbors( username )
  # the URL for the most recent weekly chart
  neighbor_url = "http://ws.audioscrobbler.com/1.0/user/#{CGI.escape(username)}/neighbours.xml"

  # load the neighbors
  document = fetch_xml_document(neighbor_url)

  # create a new artist dictionary
  neighbors = Hash.new

  # use an XPath to find all the artists in the chart and print a list of their number of plays
  document.root.get_elements('//user').each do |neighbor|
    neighbor_username = neighbor.attributes['username'].to_s
    puts "ngb: Processing neighbor #{neighbor_username}"
    neighbors[neighbor_username] = parse_ranked_artists(neighbor_username)
  end
  
  neighbors
end

# 1: load my overall artist chart, and load its bands and rankings
my_ranked_artists = parse_ranked_artists(my_name)
my_artist_set = Set.new my_ranked_artists.keys
combined_artists = Hash.new

# 2: load my neighbors' rankings, populating the global list of artists

neighbors = parse_neighbors(my_name)

my_ranked_artists.keys.each do |artist|
  if not combined_artists[artist] then
    combined_artists[artist] = Set.new [my_name]
  else
    combined_artists[artist] += my_name
  end
  parse_fans(artist, neighbors)
end

neighbors.keys.each do |username|
  neighbor_ranked_artists = neighbors[username]
  neighbor_ranked_artists.keys.each do |artist|
    if not combined_artists[artist] then
      combined_artists[artist] = Set.new [username]
    else
      combined_artists[artist] += username
    end
  end
end

puts "gen: there are #{combined_artists.size} artists in the working set."
combined_artists.keys.sort{ |a,b| a <=> b }.each do |artist|
  puts "gen: #{artist} has fans #{combined_artists[artist].to_a.join ','}"
end

ranked_neighbors = Hash.new

neighbors.keys.each do |username|
  neighbor_ranked_artists = neighbors[username]
  neighbor_artist_set = Set.new neighbor_ranked_artists.keys

  unified_artists = my_artist_set.union(neighbor_artist_set)
  intersect_artists = my_artist_set.intersection(neighbor_artist_set)

  neighbor_rank = 0

  intersect_artists.each do |artist|
    # 3: for each neighbor loaded, calculate Σ ( difference in ranks / cardinality of union of artists )
    difference = (my_ranked_artists[artist] - neighbor_ranked_artists[artist]).abs
    spoiler_scale = (neighbors.size - combined_artists[artist].size) / neighbors.size.to_f
    rank = ((unified_artists.size - difference) / unified_artists.size.to_f) * spoiler_scale
    puts "gen: username #{username} has artist #{artist} with difference #{difference}, scale #{spoiler_scale} and rank #{rank}"
    neighbor_rank += rank
  end
  
  ranked_neighbors[username] = neighbor_rank.to_f / combined_artists.size
end

ranked_neighbors.keys.sort { |a,b| ranked_neighbors[a] <=> ranked_neighbors[b] }.reverse.each do |username|
  puts "out: #{username} has a ranking of #{ranked_neighbors[username]}"
end
