class Casting < ActiveRecord::Migration
  def self.up
		#connection.execute(%q{
		#    alter table ratings
		#    alter column user_id
		#    type integer using cast(user_id as integer)
		#})
		#connection.execute(%q{
		#    alter table ratings
		#    alter column post_id
		#    type integer using cast(post_id as integer)
		#})
		#connection.execute(%q{
		#    alter table notifications
		#    alter column user_id
		#    type integer using cast(user_id as integer)
		#})
		#connection.execute(%q{
		#    alter table notifications
		#    alter column post_id
		#    type integer using cast(post_id as integer)
		#})
  end

  def self.down
  end
end
