class CreateTierBadges < ActiveRecord::Migration
  def change
    create_table :tier_badges do |t|
      t.integer :tier_id
      t.integer :badge_id

      t.timestamps
    end
  end
end
