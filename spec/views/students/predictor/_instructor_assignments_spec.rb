# encoding: utf-8
require 'spec_helper'

describe "students/predictor/_instructor_assignments" do

  before(:each) do
    clean_models
    @course = create(:course)
    assignment_types = [create(:assignment_type, course: @course, max_value: 1000)]
    assignment = create(:assignment, :assignment_type => assignment_types[0])
    @course.assignments << assignment
    student = create(:user)
    student.courses << @course
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(student)
    view.stub(:current_student_data).and_return(StudentData.new(student, @course))
  end

  it "renders" do
    render
  end
end
