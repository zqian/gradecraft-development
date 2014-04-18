class AddDurableToTiers < ActiveRecord::Migration
  def change
    change_table :tiers do |t|
      t.boolean :durable
    end
  end
end
