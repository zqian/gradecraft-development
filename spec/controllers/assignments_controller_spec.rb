require 'spec_helper'

describe AssignmentsController do

  context "as a student" do
    before do
      @course = create(:course)
      @user = create(:user)
      @user.courses << @course
      login_user
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET index" do
      it "redirects to syllabus path" do
        (get :index).should redirect_to("/syllabus")
      end
    end
  end

  context "as a professor" do
    before do
      @course = create(:course)
      @user = create(:user)
      @user.courses << @course
      @membership = CourseMembership.where(user: @user, course: @course).first.update(role: "professor")
      login_user
      session[:course_id] = @course.id
      allow(EventLogger).to receive(:perform_async).and_return(true)
    end

    describe "GET index" do
      it "redirects to syllabus path" do
        assignment_type = create(:assignment_type, course: @course)
        assignment = create(:assignment, assignment_type: assignment_type)
        @course.assignments << assignment

        get :index
        assigns(:title).should eq("assignments")
        assigns(:assignment_types).should eq([assignment_type])
        assigns(:assignments).should eq([assignment])
      end
    end
  end
end
