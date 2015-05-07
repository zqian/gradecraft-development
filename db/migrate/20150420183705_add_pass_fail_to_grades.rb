class AddPassFailToGrades < ActiveRecord::Migration
  def change
    add_column :grades, :pass_fail_status, :string
  end
end
