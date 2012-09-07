class CourseGradeSchemeElement < ActiveRecord::Base
  attr_accessible :letter_grade, :low_range, :high_range, :name, :course_grade_scheme_id
  
  belongs_to :course_grade_scheme

  def element_name
    if name?
      name
    else 
      letter_grade
    end
  end

end