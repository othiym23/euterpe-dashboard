class CreateAlbums < ActiveRecord::Migration
  def self.up
    create_table :albums do |t|
      t.column :name, :string
      t.column :subtitle, :string
      t.column :version_name, :string
      t.column :sort_order, :string
      t.column :artist_name, :string
      t.column :number_of_discs, :integer
      t.column :genre_id, :integer
      t.column :release_date, :string
      t.column :compilation, :boolean
      t.column :mixer, :string
      t.column :musicbrainz_album_id, :string
      t.column :musicbrainz_album_artist_id, :string
      t.column :musicbrainz_album_type, :string
      t.column :musicbrainz_album_status, :string
      t.column :musicbrainz_album_release_country, :string
    end
  end

  def self.down
    drop_table :albums
  end
end
