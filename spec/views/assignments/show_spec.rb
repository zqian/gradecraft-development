# encoding: utf-8
require 'spec_helper'

describe "assignments/show" do

  before(:each) do
    @course = create(:course)
    @assignment_type = create(:assignment_type, course: @course, max_value: 1000)
    @assignment = create(:assignment, :assignment_type => @assignment_type)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    assign(:title, @assignment.name)
    assign(:assignment, @assignment)
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student_data).and_return(StudentData.new(@student, @course))
  end

  describe "as student" do

    before(:each) do
      view.stub(:current_user).and_return(@student)
    end

    it "renders the assignment grades" do
      render
      assert_select "h3", :count => 1
    end

    describe "pass fail assignment" do
      it "renders pass/fail instead of the points possible in the guidelines" do
        @assignment.update(pass_fail: true)
        render
        assert_select ("div.italic.not_bold"), text: "Pass/Fail Assignment"
      end
    end
  end

  describe "as faculty" do
    it "renders the assignment management view" do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("Assignment")
      assign(:students, [@student])
      assign(:assignment_grades_by_student_id, {@student.id => nil})
      render
      assert_select "h3", text: "#{@assignment.name} (#{ points @assignment.point_total} points)"
    end

    it "renders the assignment management view when submissions are on" do
      @assignment.update(accepts_submissions: true)
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("Assignment")
      assign(:students, [@student])
      assign(:assignment_grades_by_student_id, {@student.id => nil})
      render
      assert_select "h3", text: "#{@assignment.name} (#{ points @assignment.point_total} points)"
    end

    describe "pass fail assignments" do
      it "renders pass/fail in the points field" do
        @assignment.update(pass_fail: true)
        render
        assert_select "h3", text: "#{@assignment.name} (Pass/Fail)"
      end
    end
  end
end
