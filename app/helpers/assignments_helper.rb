module AssignmentsHelper
  def assignment_has_rubric?(assignment)
    "Yes" if assignment.has_rubric?
  end
end
