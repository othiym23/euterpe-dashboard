module Euterpe
  module Dashboard
    class Disc < ActiveRecord::Base
      belongs_to :album
      has_many :tracks
    end
  end
end
