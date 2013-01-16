# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110523112216) do

  create_table "comments", :force => true do |t|
    t.text     "comment"
    t.integer  "users_id"
    t.integer  "posts_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "private",    :default => true
  end

  create_table "favourites", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifications", :force => true do |t|
    t.string   "user_id"
    t.string   "post_id"
    t.string   "controller"
    t.string   "action"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "users_id"
    t.integer  "rank",         :default => 1
    t.integer  "owner_id"
    t.string   "status",       :default => "open"
    t.boolean  "anon",         :default => false
    t.boolean  "published",    :default => false
    t.boolean  "flagged",      :default => false
    t.boolean  "deleted",      :default => false
    t.boolean  "completed",    :default => false
    t.integer  "completed_by"
  end

  create_table "ratings", :force => true do |t|
    t.string   "user_id"
    t.string   "post_id"
    t.integer  "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                :default => "",    :null => false
    t.string   "encrypted_password",    :limit => 128, :default => "",    :null => false
    t.string   "password_salt",                        :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                        :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "twitter_handle"
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_secret"
    t.boolean  "admin",                                :default => false
    t.boolean  "append_twitter_handle",                :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["twitter_handle"], :name => "index_users_on_twitter_handle", :unique => true
  add_index "users", ["twitter_oauth_token", "twitter_oauth_secret"], :name => "index_users_on_twitter_oauth_token_and_twitter_oauth_secret"

end
