class ScoreRecalculator
  include Sidekiq::Worker

  def perform(student_id, course_id)
    student = User.find(student_id)
    student.cache_course_score(course_id)
  end
end
