class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.column :name, :string, :default => "", :null => false
      t.column :sort_order, :string, :default => "", :null => false
      t.column :artist_name, :string, :default => "", :null => false
      t.column :artist_sort_order, :string, :default => "", :null => false
      t.column :remix, :string, :default => "", :null => false
      t.column :sequence, :integer, :default => 0, :null => false
      t.column :genre_id, :integer, :null => false
      t.column :disc_id, :integer, :null => false
      t.column :comment, :string, :default => "", :null => false
      t.column :encoder, :string, :default => "", :null => false, :limit => 255
      t.column :release_date, :string, :default => "", :null => false
      t.column :unique_id, :string, :default => "", :null => false
      t.column :musicbrainz_artist_id, :string, :default => "", :null => false
    end
  end

  def self.down
    drop_table :tracks
  end
end
