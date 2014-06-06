class CreateMetricBadges < ActiveRecord::Migration
  def change
    create_table :metric_badges do |t|
      t.integer :metric_id
      t.integer :badge_id

      t.timestamps
    end
  end
end
