class RepairSchemaErrors < ActiveRecord::Migration

  # get rescued from hell
  def up
    if Rails.env.production? or Rails.env.staging?

      create_table "metric_badges" do |t|
        t.integer  "metric_id"
        t.integer  "badge_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end
   
      create_table "tier_badges" do |t|
        t.integer  "tier_id"
        t.integer  "badge_id"
        t.datetime "created_at"
        t.datetime "updated_at"
      end

      change_column :assignment_types, :notify_released, :boolean, default: true
      add_column :assignment_types, :is_attendance, :boolean
      add_column :assignment_types, :has_winners, :boolean
      add_column :assignment_types, :num_winner_levels, :integer

      change_column :assignments, :notify_released, :boolean, default: true

    end
  end

  # go back to hell for no reason evident to any human living or otherwise
  def down
    if Rails.env.production? or Rails.env.staging?
      drop_table "metric_badges"
      drop_table "tier_badges"

      change_column :assignment_types, :notify_released, :boolean
      remove_column :assignment_types, :is_attendance
      remove_column :assignment_types, :has_winners
      remove_column :assignment_types, :num_winner_levels

      change_column :assignments, :notify_released, :boolean, default: true

    end
  end
end
