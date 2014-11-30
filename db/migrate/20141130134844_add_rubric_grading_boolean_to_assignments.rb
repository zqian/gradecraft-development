class AddRubricGradingBooleanToAssignments < ActiveRecord::Migration
  def change
    add_column :assignments, :use_rubric_grading, :boolean, default: false
  end
end
