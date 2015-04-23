# encoding: utf-8
require 'spec_helper'

describe "info/grading_status", focus: true do

  before(:all) do
    @title = "Unspecified Title"
    @course = create(:course)
    @team = create(:team, course: @course)
    @assignment_types = [create(:assignment_type, course: @course, max_value: 1000)]
    @assignment = create(:assignment, :assignment_type => @assignment_types[0])
    @student = create(:user)
    @grades = create(:grades, course: @course, assignment: @assignment, student: @student)
  end

  before(:each) do
    assign(:assignment_types, @assignment_types)
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student_data).and_return(StudentData.new(@student, @course))
    view.stub(:current_course_data).and_return(CourseData.new(@course))
    view.stub(:term_for).and_return("custom_term")
  end

  describe "as student" do
    before(:each) do
      #view.stub(:current_student).and_return(@student)
    end
  end

  describe "as faculty" do
    it "renders the instructor grade managment menu" do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("custom_term")
      assign(:students, [@student])
      assign(:assignment_grades_by_student_id, {@student.id => nil})
      render
      assert_select "li", text: "Grade", :count => 1
    end
  end
end
