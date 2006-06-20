class CreateDiscBuckets < ActiveRecord::Migration
  def self.up
    create_table :disc_buckets do |t|
      t.column :file_created_on, :timestamp, :null => false
      t.column :file_updated_on, :timestamp, :null => false
      t.column :path, :string, :default => "", :null => false, :limit => 255
    end
  end

  def self.down
    drop_table :disc_buckets
  end
end
