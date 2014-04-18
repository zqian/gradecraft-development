class RenameTierOrderToSortOrder < ActiveRecord::Migration
  def self.up
    rename_column :tiers, :order, :sort_order
  end

  def self.down
    rename_column :tiers, :sort_order, :order
  end
end
