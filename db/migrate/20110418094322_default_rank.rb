class DefaultRank < ActiveRecord::Migration
  def self.up
    change_column :posts, :rank, :integer, :default => 1
  end

  def self.down
    change_column :posts, :rank, :integer, :default => 0
  end
end
