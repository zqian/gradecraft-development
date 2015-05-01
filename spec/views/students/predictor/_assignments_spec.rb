# encoding: utf-8
require 'spec_helper'

describe "students/predictor/_assignments" do

  before(:each) do
    clean_models
    @course = create(:course)
    assignment_types = [create(:assignment_type, course: @course)]
    @assignment = create(:assignment, :assignment_type => assignment_types[0])
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
    view.stub(:current_student_data).and_return(StudentData.new(@student, @course))
  end

  describe "with predictable assignments" do
    it "renders" do
      @course.assignment_types[0].has_predictable_assignments?.should be_true
      render
    end

    describe "when student's score for assignment type is greater than zero" do
      it "renders the points earned" do
        @grade = create(:scored_grade, assignment: @assignment, student: @student)
        render
        assert_select "div.right.radius.label.success", count: 1
      end
    end

    describe "when student's score for assignment type is zero" do
      it "renders the points possible" do
        render
        assert_select "div.right.radius.label.fade", count: 1
      end
    end

    describe "with a pass fail assignment" do
      it "renders a pass/fail switch" do
        render
        assert_select "div.right.radius.label.fade", count: 1
      end
    end
  end
end
