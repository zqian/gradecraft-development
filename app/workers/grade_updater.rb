class GradeUpdater
  include Sidekiq::Worker

  def perform(grade_ids)
    grades = Grade.where(id: grade_ids).includes(:assignment).load
    grades.each do |grade|
      begin
        grade.cache_student_and_team_scores
        Rails.logger.debug("done grade id #{grade.id}")
        if grade.assignment.notify_released? && grade.is_released?
          #NotificationMailer.grade_released(grade.id).deliver
        end
      rescue Exception => e
        Rails.logger.error(e)
      end
    end
  end
end
