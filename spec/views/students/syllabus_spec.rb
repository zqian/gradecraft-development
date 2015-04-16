# encoding: utf-8
require 'spec_helper'

describe "students/syllabus" do

  before(:all) do
    @course = create(:course)
    @assignment_type = create(:assignment_type, course: @course, max_value: 1000)
    @assignment = create(:assignment, :assignment_type => @assignment_type)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
  end

  before(:each) do
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
    view.stub(:current_student_data).and_return(StudentData.new(@student, @course))
  end

  it "renders the points possible for the assignment" do
    render
    assert_select "div.italic.not_bold", text: "#{points @assignment.point_total} points possible", count: 1
  end

  describe "when an assignment is pass fail" do
    it "renders Pass/Fail in the points possible field when incomplete" do
      @assignment.update(pass_fail: true)
      render
      assert_select "td", text: "Pass/Fail", count: 1
    end

    it "renders Passed or Failed in the points possible field when complete" do
      @assignment.update(pass_fail: true)
      pending
      render
      assert_select "td", text: "Pass/Fail", count: 1
    end
  end

  # TODO define important implications for student weightable assigment types
  describe "when an assignment is student weightable" do
    it "renders" do
      view.stub(:term_for).and_return "Weights"
      @assignment_type.update(student_weightable: true)
      render
    end
  end
end
