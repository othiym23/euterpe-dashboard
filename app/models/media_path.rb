module Euterpe
  module Dashboard
    class MediaPath < ActiveRecord::Base
      has_one :track
      
      def MediaPath.most_recent_media_path
        most_recent_time = MediaPath.maximum(:file_updated_on, :conditions => "path ILIKE '%.mp3'")
        MediaPath.find_by_file_updated_on(most_recent_time)
      end
      
      def changed?
        file_updated_on != File.stat(path).mtime
      end
    end
  end
end
