# encoding: utf-8
require 'spec_helper'

class MockCurrentStudent
  def initialize(present)
    @present = present
  end

  def present?
    @present
  end
end

describe "assignments/_guidelines" do

  before(:all) do
    @course = create(:course)
  #   # @assignment_type = create(:assignment_type, course: @course, max_value: 2000)
    @assignment = create(:assignment)
  #   @course.assignments <<[@assignment]
    # @student = create(:user)
    # @student.courses << @course
  end

  before(:each) do
    assign(:title, "Assignment")
    assign(:assignmet, @assignment)
    # assign(:students, [@student])
    # # assign(:assignment_types, [@assignment_type_1,@assignment_type_2])
    view.stub(:current_course).and_return(@course)
    view.stub(:term_for).and_return("Assignment")
    # view.stub(:current_course_data).and_return(CourseData.new(@course))
  end

  describe "as student" do
    pending
    it "renders the assignment grades" do
      view.stub(:current_student).and_return(MockCurrentStudent.new(true))
      render
      assert_select "div.italic.not_bold", text: "#{points @assignment.point_total} points possible", :count => 1
    end
  end

  describe "as faculty" do
    it "renders the assignment management view" do
      view.stub(:current_student).and_return(MockCurrentStudent.new(false))
      render
      assert_select "div.italic.not_bold", text: "#{points @assignment.point_total} points possible", :count => 1
    end
  end
end
