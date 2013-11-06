class AddAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, default: "Been There User"
    add_column :users, :image, :string, default: APP_CONFIG['host'] + "/assets/anonymous_user.png"
    add_column :users, :fb_uid, :string
    add_column :users, :fb_access_token, :string
    remove_column :users, :uid
  end
end
