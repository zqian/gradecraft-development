# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "assignments/individual/graded/_table_body" do

  before(:each) do
    clean_models
    course = create(:course)
    @assignment_type = create(:assignment_type)
    @assignment = create(:assignment, assignment_type: @assignment_type)
    course.assignments << @assignment
    student = create(:user)
    student.courses << course
    @grade = create(:grade, course: course, assignment: @assignment, student: student)
    @students = [student]
    @assignment_grades_by_student_id = {student.id => @grade}
    view.stub(:current_course).and_return(course)
  end

  it "renders successfully" do
    render
  end

  describe "with a graded grade" do

    before(:each) do
      @grade.update(status: "Graded")
      view.stub(:remove_grades_assignment_path).and_return("#")
    end

    describe "with a score" do
      it "renders the raw score" do
        @grade.update(raw_score: @assignment.point_total)
        render
        assert_select "td", text: "#{points @grade.raw_score}"
      end
    end

    describe "with a pass fail assignment type" do
      it "renders pass/fail status" do
        @assignment.update(pass_fail: true)
        @grade.update(pass_fail_status: "Pass")
        render
        assert_select "td", text: @grade.pass_fail_status
      end
    end
  end
end
