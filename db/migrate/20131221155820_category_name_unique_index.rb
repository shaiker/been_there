class CategoryNameUniqueIndex < ActiveRecord::Migration
  def up
    add_index :categories, :name, unique: true
  end

  def down
  end
end
