# encoding: utf-8
require 'spec_helper'
include CourseTerms

describe "badges/index" do

  before(:all) do
    clean_models
    @course = create(:course)
    @badge_1 = create(:badge, course: @course, point_total: 1000)
    @badge_2 = create(:badge, course: @course, point_total: 0)
    @course.badges <<[@badge_1, @badge_2]
  end

  before(:each) do
    assign(:title, "Badges")
    view.stub(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Badges", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 2
    end
  end
end
