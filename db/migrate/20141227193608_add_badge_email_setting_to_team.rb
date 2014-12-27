class AddBadgeEmailSettingToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :badge_email_type, :string
  end
end
