class RemoveRoleFromUser < ActiveRecord::Migration
  def change
    if column_exists? :users, :role
      remove_column :users, :role, :string
    end
  end
end
