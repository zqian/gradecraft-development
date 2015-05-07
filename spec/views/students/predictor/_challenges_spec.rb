# encoding: utf-8
require 'spec_helper'

describe "students/predictor/_challenges" do

  before(:each) do
    clean_models
    @course = create(:course, team_challenges: true)
    challenge = create(:challenge, course: @course)
    student = create(:user)
    student.courses << @course
    team = create(:team, course: @course)
    team_membership = create(:team_membership, team: team, student: student)
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(student)
    view.stub(:current_student_data).and_return(StudentData.new(student, @course))
    view.stub(:term_for).and_return("challenges")
  end

  describe "with team challenges" do
    it "renders" do
      @course.team_challenges?.should be_true
      render
    end
  end
end
