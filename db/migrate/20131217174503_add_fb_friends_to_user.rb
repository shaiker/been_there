class AddFbFriendsToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_friends, :text
    add_index :users, :fb_uid
  end
end
