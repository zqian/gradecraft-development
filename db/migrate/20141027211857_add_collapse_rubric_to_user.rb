class AddCollapseRubricToUser < ActiveRecord::Migration
  def change
    add_column :users, :collapse_rubric_overview, :boolean, default: false
  end
end
