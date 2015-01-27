# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  context "attributes" do
    before(:each) do
      @course = create(:course)
      @student = create(:user)
      @earned_badges = create_list(:badge, 3)
      @unearned_badges = create_list(:badge, 2)
    end

    it "should know which badges a student has earned" do
      @student.student_visible_badges(@course).should == @earned_badges
    end

    it "should know which badges a student has yet to earn" do
      @student.student_visible_badges(@course).should == @unearned_badges
    end
  end
end
