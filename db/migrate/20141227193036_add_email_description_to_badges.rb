class AddEmailDescriptionToBadges < ActiveRecord::Migration
  def change
    add_column :badges, :email_description, :text
  end
end
