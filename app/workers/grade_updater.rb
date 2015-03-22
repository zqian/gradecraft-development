class GradeUpdater
  include Sidekiq::Worker

  def perform(grade_id)
    grade = Grade.where(id: grade_id).includes(:assignment).load
    grade.cache_student_and_team_scores
    if grade.assignment.notify_released?
      NotificationMailer.grade_released(grade.id).deliver
    end
  end
end
