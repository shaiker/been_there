class AddIndexToFollowships < ActiveRecord::Migration
  def change
    add_index :followships, :follower_id
    add_index :followships, :followee_id
    add_index :followships, [:follower_id, :followee_id], unique: true
  end
end
