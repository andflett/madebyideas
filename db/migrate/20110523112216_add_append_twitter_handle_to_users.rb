class AddAppendTwitterHandleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :append_twitter_handle, :boolean, :default => false
  end

  def self.down
    remove_column :users, :append_twitter_handle
  end
end
