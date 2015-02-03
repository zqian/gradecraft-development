# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  before(:each) do
    @course = create(:course)
    @student = create(:user)
    create(:course_membership, course: @course, user: @student)
    @assignment = create(:assignment, course: @course)
    @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, student: @student)
  end

  it "should be able to earn badges" do
    @badges = create_list(:badge, 2, course: @course)
    @student.earn_badges(@badges)
    @badges_earned = @student.earned_badges.collect {|e| e.badge }.sort_by(&:id)
    expect(@badges_earned).to eq(@badges.sort_by(&:id))
  end

  it "should know which badges a student has earned" focus: true do 
    @badges = create_list(:badge, 3, course: @course)
    @student.earn_badges(@badges)
    @badges_earned = @student.earned_badges.collect {|e| e.badge }.sort_by(&:id)
    expect(@student.student_visible_earned_badges(@course)).to eq(@earned_badges)
  end

  it "should not return unearned badges as earned badges" do
    @unearned_badges = create_list(:badge, 2, course: @course)
    expect(@student.student_visible_earned_badges(@course)).not_to include(@unearned_badges)
  end

  it "should know which badges are unique to those student earned badges" do
  end

  it "should not return badges associated with student-unearned badges" do
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
