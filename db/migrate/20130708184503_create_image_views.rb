class CreateImageViews < ActiveRecord::Migration
  def change
    create_table :image_views do |t|
      t.integer :image_id
      t.integer :user_id

      t.timestamps
    end
  end
end
