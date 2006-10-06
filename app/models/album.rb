module Euterpe
  module Dashboard
    class Album < ActiveRecord::Base
      has_many :discs
      belongs_to :genre
      
      def Album.find_generously(search_term)
        disc_join = 'INNER JOIN discs ON discs.album_id = albums.id'
        album_conditions =<<-GENIUS
               albums.name ILIKE :criterion
            OR albums.artist_name ILIKE :criterion
            OR genre_id IN (SELECT id
                              FROM genres
                             WHERE name ILIKE :criterion)
            OR discs.id IN (SELECT disc_id
                              FROM tracks
                             WHERE tracks.name ILIKE :criterion
                                OR tracks.artist_name ILIKE :criterion
                                OR genre_id IN (SELECT id
                                                  FROM genres
                                                 WHERE name ILIKE :criterion))
        GENIUS

        album_list = find(:all,
                          :joins => disc_join, 
                          :include => [:genre, :discs],
                          :order => 'albums.artist_name, albums.name',
                          :conditions => [album_conditions, {:criterion => "%#{search_term}%"}])
      end
      
      def Album.find_random
        lucky_winner = rand(count)
        find(:first, :offset => lucky_winner)
      end
      
      def Album.find_most_recently_modified
        path = MediaPath.most_recent_media_path
        path.track.disc.album if path
      end
    end
  end
end
