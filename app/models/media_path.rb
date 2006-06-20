module Euterpe
  module Dashboard
    class MediaPath < ActiveRecord::Base
      def changed?
        file_updated_on != File.stat(path).mtime
      end
    end
  end
end
