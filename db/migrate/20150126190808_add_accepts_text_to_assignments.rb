class AddAcceptsTextToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :accepts_text, :boolean
  end
end
