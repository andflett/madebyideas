class AddCompletedByToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :completed_by, :integer
  end

  def self.down
    remove_column :posts, :completed_by
  end
end
