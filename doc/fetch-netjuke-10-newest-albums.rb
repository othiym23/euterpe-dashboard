#!/usr/bin/env ruby

# load MySQL class
require 'mysql'
require 'parsedate'

netjuke_query = "
    SELECT MAX(netjuke_artists.name) AS artist_name,
           netjuke_albums.name AS album_name,
           MIN(netjuke_tracks.date) AS first_seen
      FROM netjuke_albums, netjuke_artists, netjuke_tracks
     WHERE netjuke_albums.id = netjuke_tracks.al_id
           AND netjuke_artists.id = netjuke_tracks.ar_id
  GROUP BY netjuke_albums.name
  ORDER BY first_seen DESC
     LIMIT 10"

trainspotter_query = "
    SELECT artists.name AS artist_name,
           albums.title AS album_name,
           albums.created_on AS first_seen
      FROM albums, artists
     WHERE artists.id = albums.artist_id
     ORDER BY first_seen DESC
     LIMIT 10"

netjuke_hostname = 'localhost'
netjuke_database = 'netjuke'
netjuke_username = 'ogd'
netjuke_password = 'WVeW5Y6K'

dbh = nil

begin
    dbh = Mysql.real_connect(netjuke_hostname,
                             netjuke_username,
                             netjuke_password,
                             netjuke_database)
    
    result_set = dbh.query(netjuke_query)
    
    result_set.each_hash do |row|
      seen_date = Time.local(*ParseDate.parsedate(row['first_seen']))
      puts "#{row['artist_name']}: #{row['album_name']} (#{seen_date.strftime("%Y/%m/%d")})"
    end
rescue MysqlError => e
    print "Error code: ", e.errno, "\n"
    print "Error message: ", e.error, "\n"
ensure
    dbh.close if dbh != nil
end
