# spec/models/user_spec.rb

require 'spec_helper'

describe User do
  it "is valid with a first name, a last name, a username, and an email address" do
    user = User.new(first_name: 'Hermione', last_name: 'Granger', email: 'hermione.granger@hogwarts.edu', username: 'crookshanks')
    expect(user).to be_valid
  end

  it "is invalid without a first name" do
    expect(User.new(first_name: nil)).to have(1).errors_on(:first_name)
  end

  it "is invalid without a last name" do
    expect(User.new(last_name: nil)).to have(1).errors_on(:last_name)
  end

  it "is invalid without a username" do
    expect(User.new(username: nil)).to have(1).errors_on(:username)
  end

  it "is invalid without an email address" do
    pending
    expect(User.new(email: nil)).to have(3).errors_on(:email)
  end

  it "returns a user's full name as a string" do
    user = User.new(first_name: 'Hermione', last_name: 'Granger', email: 'hermione.granger@hogwarts.edu', username: 'crookshanks')
    expect(user.name).to eq 'Hermione Granger'
  end

  context "finding earned and unearned badges" do
    before(:all) do
      @course = create(:course)
      @student = create(:user)
      create(:course_membership, course: @course, user: @student)
      @assignment = create(:assignment, course: @course)
      @grade = create(:grade, assignment: @assignment, assignment_type: @assignment.assignment_type, course: @course, user: @student)

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
