#!/usr/bin/env ruby

# load MySQL class
require 'mysql'

query = "
    SELECT COUNT( netjuke_tracks.id ) AS tracks,
                  netjuke_genres.name AS genre
      FROM netjuke_tracks, netjuke_genres
     WHERE netjuke_tracks.ge_id = netjuke_genres.id
  GROUP BY netjuke_genres.name
  ORDER BY tracks DESC
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
      puts "#{row['genre']} (#{row['tracks']})"
    end
rescue MysqlError => e
    print "Error code: ", e.errno, "\n"
    print "Error message: ", e.error, "\n"
ensure
    dbh.close if dbh != nil
end
