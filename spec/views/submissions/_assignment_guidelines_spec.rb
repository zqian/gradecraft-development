# encoding: utf-8
require 'spec_helper'

describe "submissions/_assignment_guidelines" do

  before(:each) do
    @course = create(:course)
    @assignment = create(:assignment)
    view.stub(:current_course).and_return(@course)
  end

  describe "with a graded assignment" do
    it "renders Pass/Fail and not the points total" do
      render
      assert_select "div.italic.not_bold", text: "#{points @assignment.point_total} points possible", count: 1
    end
  end

  describe "with a pass fail assignment"  do
    it "renders Pass/Fail and not the points total" do
      @assignment.update(pass_fail: true)
      render
      assert_select "div.italic.not_bold", text: "#{points @assignment.point_total} points possible", count: 0
      assert_select "div.italic.not_bold", text: "Pass/Fail Assignment", count: 1
    end
  end
end
