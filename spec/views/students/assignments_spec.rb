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
  end

  describe "as student" do
    it "does not render instructor menu" do
      view.stub(:current_student).and_return(@student)
      render
      assert_select "li", text: "Grade", :count => 0
    end
  end  

  describe "as faculty" do
    it "renders the instructor grade managment menu" do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("Assignment")
      assign(:students, [@student])
      assign(:assignment_grades_by_student_id, {@student.id => nil})      
      render
      assert_select "li", text: "Grade", :count => 1
    end
  end
end
