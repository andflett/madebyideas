class EmailNotifications < ActiveRecord::Migration
  def self.up
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :post_id
      t.string :controller
      t.string :action
      t.string :value
      t.timestamps
    end
    add_column :posts, :anon, :boolean, :default => false
  end

  def self.down
    drop_table :notifications
    remove_column :posts, :anon
  end
end
