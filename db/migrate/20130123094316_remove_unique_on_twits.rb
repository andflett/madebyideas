class RemoveUniqueOnTwits < ActiveRecord::Migration
  def self.up
		remove_index :users, :twitter_handle
  end

  def self.down
  end
end
