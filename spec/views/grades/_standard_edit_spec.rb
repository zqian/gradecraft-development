# encoding: utf-8
require 'spec_helper'

describe "grades/_standard_edit" do

  before(:each) do
    clean_models
    @course = create(:course)
    @assignment = create(:assignment)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    @grade = create(:grade, course: @course, assignment: @assignment, student: @student)

    view.stub(:current_student).and_return(@student)
    current_user = double()
    current_user.stub(:id) {0}
    view.stub(:current_user).and_return(current_user)
  end

  describe "when an assignment has point values" do
    it "renders the points possible when incomplete" do
      render
      assert_select "label", text: "Raw Score (#{@assignment.point_total} Points Possible)", count: 1
    end
  end

  describe "when an assignment is pass fail" do

    before(:each) do
      @assignment.update(pass_fail: true)
    end

    it "renders Pass/Fail in the points possible field when incomplete" do
      render
      assert_select "label", text: "Raw Score (0 Points Possible)", count: 0
      assert_select "label", text: "Pass fail status", count: 1
    end

    it "renders the switch in the passed position when not yet graded" do
      render
      assert_select ".switch-label", text: "Passed", count: 1
      assert_select ".switch" do
        assert_select "#grade_pass_fail_status[value=Passed]", count: 1
      end
    end

    it "renders the switch in the passed position when grade status is 'Passed'" do
      @grade.update(pass_fail_status: "Passed")
      render
      assert_select ".switch-label", text: "Passed", count: 1
      assert_select ".switch" do
        assert_select "#grade_pass_fail_status[value=Passed]", count: 1
      end
    end

    it "renders the switch in the failed position when the grade is 'Failed'" do
      @grade.update(pass_fail_status: "Failed")
      render
      assert_select ".switch-label", text: "Failed", count: 1
      assert_select ".switch" do
        assert_select "#grade_pass_fail_status[value=Passed]", count: 1
      end
    end
  end
end
