class Track < ActiveRecord::Base
  belongs_to :disc, :include => :album
  belongs_to :genre
  belongs_to :media_path
  
  has_and_belongs_to_many :artists
  
  validates_presence_of :artist_name
  validates_presence_of :name
  
  def file_changed?
    media_path.changed?
  end
  
  def Track.pending_count
    count_by_sql('SELECT COUNT(*) FROM tracks')
  end
end
