class RemoveDefunctCols < ActiveRecord::Migration
  def self.up
    remove_column :posts, :photo_uid
    remove_column :posts, :place_name
    remove_column :posts, :place_lat
    remove_column :posts, :place_lng
    remove_column :posts, :place_id
    add_column :posts, :owner_id, :integer
    add_column :posts, :status, :string, :default => 'open'
  end

  def self.down
  end
end
