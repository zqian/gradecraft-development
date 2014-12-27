class AddBadgeEmailSettingToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :badge_emails, :boolean, :default => false
  end
end
