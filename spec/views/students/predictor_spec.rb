# encoding: utf-8
require 'spec_helper'

describe "students/predictor" do

  before(:each) do
    @course = create(:course)
    @student = create(:user)
    view.stub(:current_course).and_return(@course)
    view.stub(:current_student).and_return(@student)
    @student.stub(:cached_score_for_course).and_return(0)
  end

  describe "as student" do
    before(:each) do
      view.stub(:current_user_is_staff?).and_return(false)
      view.stub(:current_user_is_student?).and_return(true)
    end

    it "renders" do
      render
    end
  end

  describe "as staff" do
    before(:each) do
      view.stub(:current_user_is_staff?).and_return(true)
      view.stub(:term_for).and_return("")
    end

    it "renders" do
      render
    end
  end
end
