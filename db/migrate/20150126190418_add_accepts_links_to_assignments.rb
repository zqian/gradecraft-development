class AddAcceptsLinksToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :accepts_links, :boolean
  end
end
