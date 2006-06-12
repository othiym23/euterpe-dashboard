class CreateArtists < ActiveRecord::Migration
  def self.up
    create_table :artists do |t|
      t.column :name, :string
    end

    create_table :artists_tracks do |t|
      t.column :artist_id, :integer
      t.column :track_id, :integer
    end
  end

  def self.down
    drop_table :artists
    drop_table :artists_tracks
  end
end
