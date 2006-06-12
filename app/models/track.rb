class Track < ActiveRecord::Base
  belongs_to :disc
  has_and_belongs_to_many :artists
  belongs_to :genre
end
