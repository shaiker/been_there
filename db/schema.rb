# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20140120174435) do

  create_table "been_theres", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "comments", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "feedbacks", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "followships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followee_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "followships", ["followee_id"], :name => "index_followships_on_followee_id"
  add_index "followships", ["follower_id", "followee_id"], :name => "index_followships_on_follower_id_and_followee_id", :unique => true
  add_index "followships", ["follower_id"], :name => "index_followships_on_follower_id"

  create_table "image_categories", :force => true do |t|
    t.integer  "image_id"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "image_categories", ["category_id"], :name => "index_image_categories_on_category_id"
  add_index "image_categories", ["image_id"], :name => "index_image_categories_on_image_id"

  create_table "image_views", :force => true do |t|
    t.integer  "image_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "images", :force => true do |t|
    t.integer  "user_id"
    t.string   "caption"
    t.string   "url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "images", ["user_id"], :name => "index_images_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "image_id"
    t.integer  "generated_by_user_id"
    t.integer  "notification_type"
    t.boolean  "digested",             :default => false
    t.boolean  "opened",               :default => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "push_type"
  end

  create_table "tips", :force => true do |t|
    t.string   "title"
    t.string   "text"
    t.integer  "category_id"
    t.string   "url"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "image"
  end

  create_table "users", :force => true do |t|
    t.datetime "created_at",                                                                     :null => false
    t.datetime "updated_at",                                                                     :null => false
    t.string   "name",            :default => "Been There User"
    t.string   "image",           :default => "http://www.kokavo.com/assets/anonymous_user.png"
    t.string   "fb_uid"
    t.string   "fb_access_token"
    t.text     "fb_friends"
  end

  add_index "users", ["fb_uid"], :name => "index_users_on_fb_uid"

end
