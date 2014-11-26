require 'spec_helper'

describe AssignmentsController do
  render_views

  before(:each) do
    user = create(:admin)
    session[:user_id] = user.id  
    @course = mock(Course)
    Course.stub! :new => @course
    @course.stub! :assignment_term => "Assignment"
  end

  describe "index" do  
    
    it "renders the index template" do
      get :index
      response should contain("Assignments")
    end

  end

  describe "GET 'settings'"

  describe "GET 'show'"

  describe "GET 'feed'"

  describe "GET 'new'"

  describe "POST 'create'"

  describe "POST 'copy'"

  describe "DELETE 'destroy'"

  describe "GET 'rules'"

  describe "GET 'edit'"

  describe "PUT 'update'"



end