# encoding: utf-8
require 'spec_helper'

describe "students/_assignments" do

  before(:each) do
    clean_models
    @course = create(:course)
    @assignment_types = [create(:assignment_type, course: @course, max_value: 1000)]
    @assignment = create(:assignment, :assignment_type => @assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user)
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

    describe "when an assignment has points" do

      it "renders the points possible when grade is not released" do
        render
        assert_select "td", text: "#{points @assignment.point_total} points possible", count: 1
      end

      it "renders the points out of points possible when the grade is released for assignment" do
        @assignment.update(release_necessary: false)
        @grade = create(:grade, course: @course, assignment: @assignment, student: @student, raw_score: @assignment.point_total, status: "Graded")

        # To verify we have satisfied the released condition:
        StudentData.new(@student, @course).grade_released_for_assignment?(@assignment).should be_true
        render
        assert_select "td" do
          assert_select "div", text: "#{ points @grade.score } / #{points @grade.point_total} points earned", count: 1
        end
      end
    end

    describe "when an assignment is pass fail" do

      before(:each) do
        @assignment.update(pass_fail: true)
      end

      it "renders Pass/Fail in the points possible field when grade is not released" do
        render
        assert_select "td", text: "Pass/Fail", count: 1
      end

      it "renders Passed or Failed in the points possible field when a grade is released for assignment" do
        @grade = create(:grade, course: @course, assignment: @assignment, student: @student, pass_fail_status: "Passed", status: "Graded")

        # To verify we have satisfied the released condition:
        StudentData.new(@student, @course).grade_released_for_assignment?(@assignment).should be_true

        render
        assert_select "td" do
          assert_select "div", text: "Passed", count: 1
        end
      end
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
