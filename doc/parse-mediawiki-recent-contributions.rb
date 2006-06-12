#!/usr/bin/env ruby

# load DBI, HTTP request class and REXML Document class
require 'dbi'
require 'net/http'
require 'parsedate'
require 'rexml/document'

def get_artist_name_from_netjuke(album_name)

  netjuke_hostname = 'localhost'
  netjuke_database = 'netjuke'
  netjuke_username = 'ogd'
  netjuke_password = 'WVeW5Y6K'
  
  stripped_album_match = album_name.match(/([^ \t].[^()]+[^ \t].) \(.*\)/)
  album_name = stripped_album_match[1] if stripped_album_match
  stripped_album_match = album_name.match(/\(.*\) ([^ \t].[^()]+[^ \t].)/)
  album_name = stripped_album_match[1] if stripped_album_match
  
  begin
      dbh = DBI.connect("dbi:Mysql:#{netjuke_database}:#{netjuke_hostname}", netjuke_username, netjuke_password)

      artist_query = "
        SELECT netjuke_artists.name,
               COUNT(netjuke_artists.name) AS count
          FROM netjuke_artists, netjuke_tracks, netjuke_albums
         WHERE UPPER(netjuke_albums.name) LIKE UPPER( ? )
               AND netjuke_tracks.al_id = netjuke_albums.id
               AND netjuke_tracks.ar_id = netjuke_artists.id
      GROUP BY netjuke_artists.name
      ORDER BY count DESC"
      statement = dbh.prepare(artist_query)
      statement.execute("%#{album_name}%")
      artist_list = []

      statement.fetch do |row|
        artist_list << row[0]
      end
      statement.finish
  rescue DBI::DatabaseError => e
      puts "An error occurred"
      puts "Error code: #{e.err}"
      puts "Error message: #{e.errstr}"
  end
  
  artist_string = artist_list.join(", ")
  if artist_string.length > 32
    artist_string[0, 29].strip + '...'
  else
    artist_string
  end  
end

# set the username to fetch
wiki_username = 'Forrest'

http_hostname = 'audio.aoaioxxysz.net'
http_username = 'audio'
http_password = '109shoppingwarriors'
http_base_url = ''

document = ''

Net::HTTP.start(http_hostname) do |http|
  req = Net::HTTP::Get.new("#{http_base_url}/wiki/index.php/Special:Contributions/#{wiki_username}")
  req.basic_auth http_username, http_password
  response = http.request(req)
  document = REXML::Document.new(response.body)
end

li_tags = document.root.get_elements("//li/span[contains(.,'initial version')]/..")

li_tags.sort{ |a,b| Time.local(*ParseDate.parsedate(a.get_text.to_s.match( /([0-9:]+, [0-9]+ [a-zA-Z]+ [0-9]{4})/ )[0])) <=>
                    Time.local(*ParseDate.parsedate(b.get_text.to_s.match( /([0-9:]+, [0-9]+ [a-zA-Z]+ [0-9]{4})/ )[0]))
            }.reverse.each do |li|
  # 1st url is the page's history, 2nd url is the diff, 3rd url is the URL to the page, and we want it
  album_tag    = li.get_elements('a[3]').first

  date_match   = li.get_text.to_s.match( /([0-9:]+, [0-9]+ [a-zA-Z]+ [0-9]{4})/ )
  date = Time.local(*ParseDate.parsedate(date_match[0]))
  
  artist_name = get_artist_name_from_netjuke(album_tag.children.to_s)
  album_string = ""
  album_string = "#{artist_name}: " if artist_name && artist_name != ""
  album_string += "\"#{album_tag.children.to_s}\":http://#{http_hostname}#{album_tag.attributes['href']} (#{date.strftime("%Y/%m/%d")})"
  puts album_string
end

# Yeeeah... Mediawiki doesn't have a sane service API, so in order to extract a list
# of recently added albums, I need to rely on the fact that I always tag new reviews
# "initial version" and then scrape the results out of the feed
#
# Here's the XPath query below, decoded:
# 1. grab all the list elements containing a span containing the text 'initial version'
# 2. filter out all the URLs with '?title=', because those are grody editing-related ones
#   (we just want the RESTy Wikiname)
#
# (it turns out XPath doesn't have to do all the work, keeping this for "posterity")
# grody_xpath_query = "//li/span[contains(.,'initial version')]/../a[false == contains(@href,'?title=')]"
