class AddPushTypeToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :push_type, :int
  end
end
