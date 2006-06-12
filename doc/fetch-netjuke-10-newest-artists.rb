#!/usr/bin/env ruby

# load MySQL class
require 'mysql'
require 'parsedate'

netjuke_query = "
    SELECT netjuke_artists.name AS artist_name,
           MIN(netjuke_tracks.date) AS first_seen
      FROM netjuke_artists, netjuke_tracks
     WHERE netjuke_artists.id = netjuke_tracks.ar_id
  GROUP BY netjuke_artists.name
  ORDER BY first_seen DESC
     LIMIT 10"

trainspotter_query = "
    SELECT artists.name AS artist_name,
           artists.created_on AS first_seen
      FROM artists, albums
     WHERE artists.id IN (SELECT DISTINCT artist_id FROM albums)
           AND albums.artist_id = artists.id
     ORDER BY first_seen DESC"

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
      puts "#{row['artist_name']} (#{seen_date.strftime("%Y/%m/%d")})"
    end
rescue MysqlError => e
    print "Error code: ", e.errno, "\n"
    print "Error message: ", e.error, "\n"
ensure
    dbh.close if dbh != nil
end
