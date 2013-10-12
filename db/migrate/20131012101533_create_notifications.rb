class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :image_id
      t.integer :generated_by_user_id
      t.integer :notification_type
      t.boolean :digested, default: false
      t.boolean :opened, default: false

      t.timestamps
    end
  end
end
