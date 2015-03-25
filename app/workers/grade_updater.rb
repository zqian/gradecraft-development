class GradeUpdater
  @queue= :gradeupdater

  def self.perform(grade_id)
  	p "Starting GradeUpdater"
    grade = Grade.where(id: grade_id).includes(:assignment).load
    grade.cache_student_and_team_scores
    if grade.assignment.notify_released?
      NotificationMailer.grade_released(grade.id).deliver
    end
  end
end
