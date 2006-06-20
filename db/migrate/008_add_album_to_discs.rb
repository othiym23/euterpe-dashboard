class AddAlbumToDiscs < ActiveRecord::Migration
  def self.up
    add_column :discs, :album_id, :integer
  end

  def self.down
    drop_column :discs, :album_id
  end
end
