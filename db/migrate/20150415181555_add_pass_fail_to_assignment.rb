class AddPassFailToAssignment < ActiveRecord::Migration
  def change
    add_column :assignments, :pass_fail, :boolean, :default => false
  end
end
