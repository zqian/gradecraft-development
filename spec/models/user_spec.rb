# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  context "finding earned and unearned badges" do
    before(:all) do
      @course = create(:course)
      @student = create(:user)
      create(:course_membership, course: @course, user: @student)
      @assignment = create(:assignment, course: @course)
      @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, student: @student)

      @earned_badges = create_list(:badge, 3, course: @course)
      @student.earn_badges(@earned_badges)
      @unearned_badges = create_list(:badge, 2, course: @course)
    end

    it "should know which badges a student has earned" do
      @student.student_visible_badges(@course).should == @earned_badges
    end

    it "should not return unearned badges as earned badges" do
    end

    it "should know which badges a student has yet to earn" do
      @student.student_visible_unearned_badges(@course).should == @unearned_badges
    end

    it "should not return earned badges as unearned ones" do
    end
  end

  context "earning badges" do
    it "should be able to earn badges" do
      
    end
  end
end
