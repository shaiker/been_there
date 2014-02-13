class CreateFollowships < ActiveRecord::Migration
  def change
    create_table :followships do |t|
      t.integer :follower_id
      t.integer :followee_id

      t.timestamps
    end

    add_index :users, :fb_uid
  end
end
