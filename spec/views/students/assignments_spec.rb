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

    it "renders a weightable assignment types that are open" do
      pending
    end

    it "renders a weightable assignment types that are closed" do
      pending
    end

    it "shows the predictor description if it's present" do
      pending
    end

    it "highlights assignments that are required" do
      pending
    end

    it "shows a grade if it's released" do
      pending
    end

    it "shows the assignment submission if present" do
      pending
    end

    it "shows the due date if it's in the future" do
      pending
    end

    it "shows a button to see more results if the grade is released" do
      pending
    end

    it "shows a button to see the group if a group exists" do
      pending
    end

    it "shows a button to see their submission if one is present" do
      pending
    end

    it "shows a button to see the group submission if one is present" do
      pending
    end

    it "shows a button to create a group if no group is present" do
      pending
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

    it "shows a button to grade an assignment if none is present" do
      pending
    end

    it "shows a button to edit a grade for an assignment if one is present" do
      pending
    end

    it "shows a button to see their submission if one is present" do
      pending
    end

  end
end
