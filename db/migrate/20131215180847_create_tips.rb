class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.string :title
      t.string :text
      t.integer :category_id
      t.integer :image_id
      t.string :url

      t.timestamps
    end
  end
end
