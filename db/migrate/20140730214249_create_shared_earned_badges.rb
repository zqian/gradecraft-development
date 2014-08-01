class CreateSharedEarnedBadges < ActiveRecord::Migration
  def change
    create_table :shared_earned_badges do |t|
      t.integer :course_id
      t.text :student_name
      t.integer :user_id
      t.string :icon
      t.string :name
      t.integer :badge_id

      t.timestamps
    end
  end
end
