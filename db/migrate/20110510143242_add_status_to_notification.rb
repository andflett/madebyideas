class AddStatusToNotification < ActiveRecord::Migration
  def self.up
    add_column :notifications, :status, :string
  end

  def self.down
    remove_column :notifications, :status
  end
end
