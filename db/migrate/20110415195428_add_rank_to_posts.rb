class AddRankToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :rank, :integer
  end

  def self.down
    remove_column :posts, :rank
  end
end
