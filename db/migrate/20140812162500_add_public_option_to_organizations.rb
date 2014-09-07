class AddPublicOptionToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :public, :boolean, :default => false
  end

  def self.down
    remove_column :organizations, :public
  end
end
