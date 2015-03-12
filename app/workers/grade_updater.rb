class GradeUpdater
  include Sidekiq::Worker

  def perform(grade_ids)
    grades = Grade.where(id: grade_ids).includes(:assignment).load
    grades.each do |grade|
      if grade.is_released?
        grade.cache_student_and_team_scores
        # if grade.assignment.notify_released?
        #   NotificationMailer.grade_released(grade.id).deliver
        # end
      end
    end
  end
end
