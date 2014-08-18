class AddNotifiableToNotifications < ActiveRecord::Migration
  def self.up
    change_table :notifications do |t|
      t.references :notifiable, :polymorphic => true
    end

    add_index :notifications, [:user_id, :notifiable_id, :notifiable_type], :unique => true, :name => 'notifiables_index'
    add_index :notifications, [:notifiable_id, :notifiable_type]

    Notification.reset_column_information
    Notification.update_all ["notifiable_type = 'Project'"]
    Notification.update_all ["notifiable_id = project_id"]
  end

  def self.down
    change_table :notifications do |t|
      t.remove_references :notifiable, :polymorphic => true
    end
  end
end
