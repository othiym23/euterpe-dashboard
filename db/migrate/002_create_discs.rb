class CreateDiscs < ActiveRecord::Migration
  def self.up
    create_table :discs do |t|
      t.column :number, :integer
      t.column :number_of_tracks, :integer
    end
  end

  def self.down
    drop_table :discs
  end
end
