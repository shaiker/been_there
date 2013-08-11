class CreateImages < ActiveRecord::Migration
  def up
    create_table :images do |t|
      t.integer :user_id
      t.string :caption
      t.string :url

      t.timestamps
    end

    add_index :images, :user_id
  end

  def down
    drop_table :images
  end
end
