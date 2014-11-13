require 'spec_helper'

describe AssignmentsController do
  
  before(:each) do
    current_course = mock(Course) 
  end

  describe "GET 'index'" do

    it "should get all assignments for a course" do
      current_course.assignment_term = "Assignment"
      Assignment.should_receive(:all) {}
      get "index"
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