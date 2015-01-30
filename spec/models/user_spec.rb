# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  before(:all) do
    @course = create(:course)
    @student = create(:user)
    create(:course_membership, course: @course, user: @student)
    @assignment = create(:assignment, course: @course)
    @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, student: @student)
  end

  before(:each) do
    @earned_badges = create_list(:badge, 3, course: @course)
    @student.earn_badges(@earned_badges)
    @unearned_badges = create_list(:badge, 2, course: @course)
  end

  it "should know which badges a student has earned" do
    expect(@student.student_visible_badges(@course)).to eq(@earned_badges)
  end

  it "should not return unearned badges as earned badges" do
    expect(@student.student_visible_badges(@course)).not_to include(@unearned_badges)
  end

  it "should know which badges a student has yet to earn" do
    expect(@student.student_visible_unearned_badges(@course)).to eq(@unearned_badges)
  end

  it "should not return earned badges as unearned ones" do
    expect(@student.student_visible_unearned_badges(@course)).not_to include(@earned_badges)
  end

  it "should be able to earn badges" do
    
  end
end
