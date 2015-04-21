# encoding: utf-8
require 'spec_helper'

describe "students/_assignments" do

  before(:all) do
    @course = create(:course)
    @assignment_types = [create(:assignment_type, course: @course, max_value: 1000)]
    @assignment = create(:assignment, :assignment_type => @assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user)
  end

  before(:each) do
    assign(:title, "Assignment Types")
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

    it "does not render instructor menu" do
      render
      assert_select "li", text: "Grade", :count => 0
    end

    it "renders when assignment is student_logged" do
      @assignment.update(student_logged: true)
      Assignment.any_instance.stub(:open?).and_return(true)
      view.stub(:current_user_is_student?).and_return(true)
      render
    end

    it "renders with team_challenges and team_score_average" do
      @course.update(team_challenges: true)
      @course.update(team_score_average: true)
      render
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
