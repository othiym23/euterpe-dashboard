#!/usr/bin/env ruby

# load MySQL class
require 'mysql'

query = "
    SELECT COUNT(netjuke_tracks.id) AS num_tracks,
           netjuke_artists.name AS artist_name,
           MIN(netjuke_tracks.date) AS first_seen
      FROM netjuke_artists, netjuke_tracks
     WHERE netjuke_artists.id = netjuke_tracks.ar_id
  GROUP BY netjuke_artists.name
  ORDER BY num_tracks DESC
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
    
    result_set = dbh.query(query)
    
    result_set.each_hash do |row|
      puts "#{row['artist_name']} (#{row['num_tracks']} tracks)"
    end
rescue MysqlError => e
    print "Unable to fetch records from database because: ", e.error, "\n"
ensure
    dbh.close if dbh != nil
end
