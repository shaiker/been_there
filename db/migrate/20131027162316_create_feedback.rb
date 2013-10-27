class CreateFeedback < ActiveRecord::Migration
  def up
    create_table :feedbacks do |t|
      t.integer :user_id
      t.text :text

      t.timestamps
    end
  end

  def down
    drop_table :feedbacks
  end
end
