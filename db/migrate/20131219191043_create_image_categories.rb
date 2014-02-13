class CreateImageCategories < ActiveRecord::Migration
  def change
    create_table :image_categories do |t|
      t.integer :image_id
      t.integer :category_id

      t.timestamps
    end

    add_index :image_categories, :image_id
    add_index :image_categories, :category_id
  end
end
