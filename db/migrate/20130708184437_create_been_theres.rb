class CreateBeenTheres < ActiveRecord::Migration
  def change
    create_table :been_theres do |t|
      t.integer :image_id
      t.integer :user_id

      t.timestamps
    end
  end
end
