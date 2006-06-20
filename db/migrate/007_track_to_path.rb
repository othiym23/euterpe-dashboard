class TrackToPath < ActiveRecord::Migration
  def self.up
    add_column :tracks, :media_path_id, :integer
  end

  def self.down
    drop_column :tracks, :media_path_id
  end
end
