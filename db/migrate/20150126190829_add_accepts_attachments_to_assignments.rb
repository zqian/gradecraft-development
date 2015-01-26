class AddAcceptsAttachmentsToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :accepts_attachments, :boolean
  end
end
