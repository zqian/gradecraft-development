# encoding: utf-8
require 'spec_helper'

describe "grades/_individual_show" do

  before(:each) do
    clean_models
    course = create(:course)
    @assignment = create(:assignment)
    course.assignments << @assignment
    student = create(:user)
    student.courses << course
    @grade = create(:grade, course: course, assignment: @assignment, student: student)

    view.stub(:current_student).and_return(student)
    student_data = StudentData.new(student, course)
    view.stub(:current_student_data).and_return(student_data)
    view.stub(:current_course).and_return(course)

  end

  describe "viewed by staff" do
    before(:each) do
      view.stub(:current_user_is_staff).and_return(true)
    end

    describe "with a raw score" do
      it "renders the points out of possible" do
        @grade.update(status: "Graded", raw_score: @assignment.point_total)
        render
        assert_select "p" do
          assert_select "span", text: "You earned", count: 1
          assert_select "span", text: "#{points @assignment.point_total}", count: 1
        end
      end
    end

    describe "with a pass fail grade" do
      it "renders pass/fail status" do
        @assignment.update(pass_fail: true)
        @grade.update(status: "Graded", pass_fail_status: "Pass")
        render
        assert_select "p" do
          assert_select "span", text: "Pass", count: 1
          # TODO: change to term for assignment?
          assert_select "span", text: "the assignment.", count: 1
        end
      end
    end
  end

  describe "viewed by student" do
    before(:each) do
      view.stub(:current_user_is_staff).and_return(false)
    end
    it "renders" do
      render
    end
  end
end
