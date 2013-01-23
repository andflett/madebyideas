class DefaultsAgain < ActiveRecord::Migration
  def self.up
	change_column :users, :password_salt, :string, :null => true
  end

  def self.down
  end
end
