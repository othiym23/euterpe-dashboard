module Euterpe
  module Dashboard
    class Disc < ActiveRecord::Base
      belongs_to :album
      has_many :tracks, :include => [:genre, :media_path, :artists]
    end
  end
end
