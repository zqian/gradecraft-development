class ScoreRecalculator
  @queue= :scorerecalculator

  def self.perform(student_id, course_id)
  	p "Starting ScoreRecalculator"
    student = User.find(student_id)
    student.cache_course_score(course_id)
  end
end
