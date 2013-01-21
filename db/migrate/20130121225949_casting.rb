class Casting < ActiveRecord::Migration
  def self.up
		connection.execute(%q{
		    alter table ratings
		    alter column user_id
		    type integer using cast(number as integer)
		})
		connection.execute(%q{
		    alter table ratings
		    alter column post_id
		    type integer using cast(number as integer)
		})
  end

  def self.down
  end
end
