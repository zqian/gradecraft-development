class AddOrderToTiers < ActiveRecord::Migration
  def change
    add_column :tiers, :order, :integer
  end
end
