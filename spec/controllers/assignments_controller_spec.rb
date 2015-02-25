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

    describe "GET show" do

      before do
        assignment_type = create(:assignment_type, course: @course)
        @assignment = create(:assignment)
        @course.assignments << @assignment
      end

      it "returns the assignment show page" do
        get :show, {:id => @assignment.id}
        assigns(:assignment).should eq(@assignment)
        assigns(:assignment_type).should eq(@assignment.assignment_type)
        assigns(:title).should eq(@assignment.name)
      end

      it "assigns groups" do
        pending
        # @groups = @assignment.groups
        get :show, {:id => @assignment.id}
        assigns(:groups).should eq(@assignment.groups)
      end

      it "assigns assignment_grades_by_student_id" do
        pending
        #@assignment_grades_by_student_id = current_course_data.assignment_grades(@assignment)
        get :show, {:id => @assignment.id}
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          pending
          # @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
          # @students = current_course.students_being_graded_by_team(@team)
          get :show, {:id => @assignment.id}
        end

        it "assigns all team students auditing as auditing" do
          pending
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          get :show, {:id => @assignment.id}
          assigns(:students).should eq([@user])
        end

        it "assigns all auditing students as auditing" do
          @user.course_memberships.first.update(auditing: true)
          get :show, {:id => @assignment.id}
          assigns(:auditing).should eq([@user])
        end
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)

        get :show, {:id => @assignment.id}
        assigns(:rubric).should eq(rubric)
        assigns(:metrics).should eq(rubric.metrics)
      end

      it "assigns course badges" do
        pending
        #@course_badges = serialized_course_badges
        get :show, {:id => @assignment.id}
        assigns(:course_badges).should eq()
      end

      it "assigns assignment score levels" do
        pending
        #@assignment_score_levels = @assignment.assignment_score_levels.order_by_value
        get :show, {:id => @assignment.id}
        assigns(:assignment_score_levels).should eq()
      end

      it "assigns student ids" do
        get :show, {:id => @assignment.id}
        assigns(:course_student_ids).should eq([@user.id])
      end

      it "assigns data for displaying student grading distribution" do
        pending
        # add submissions, grade some
        get :show, {:id => @assignment.id}
        assigns(:submissions_count).should eq(@assignment.submissions.count)
        assigns(:ungraded_submissions_count).should eq(@assignment.ungraded_submissions.count)
        assigns(:ungraded_percentage).should eq(@assignment.ungraded_submissions.count / @assignment.submissions.count)
        assigns(:graded_count).should eq(@assignment.submissions.count - @assignment.ungraded_submissions.count)
      end

      # GET show, student specific assignments:

      it "assigns grades for assignment" do
        pending
        # add a grade for student submission
        get :show, {:id => @assignment.id}
        assigns(:grades_for_assignment).should eq(@assignment.grades_for_assignment(@user))
      end

      it "assigns rubric grades" do
        pending
        # @rubric_grades = RubricGrade.joins("left outer join submissions on submissions.id = rubric_grades.submission_id").where(student_id: current_user[:id]).where(assignment_id: params[:id])
        get :show, {:id => @assignment.id}
        assigns(:rubric_grades).should eq()
      end

      it "assigns comments by metric id" do
        pending
        get :show, {:id => @assignment.id}
        assigns(:comments_by_metric_id).should eq()
      end

      it "assigns comments by metric id" do
        pending
        get :show, {:id => @assignment.id}
        assigns(:comments_by_metric_id).should eq()
      end

      it "assigns group if student is in a group" do
        pending
        # if @assignment.has_groups? && current_student.group_for_assignment(@assignment).present?
        #   @group = current_student.group_for_assignment(@assignment)
        # end
        get :show, {:id => @assignment.id}
        assigns(:group).should eq(@user.group_for_assignment(@assignment))
      end
    end

    describe "GET guidelines" do
      it "assigns the assignment and associated rubric" do
        assignment = create(:assignment)
        @course.assignments << assignment
        rubric = create(:rubric_with_metrics, assignment: assignment)

        get :guidelines, {:id => assignment.id}
        assigns(:assignment).should eq(assignment)
        assigns(:title).should eq(assignment.name)
        assigns(:rubric).should eq(assignment.rubric)
        assigns(:metrics).should eq(assignment.rubric.metrics)
      end
    end

    describe "GET feed" do
      it "returns a calendar event" do
        assignment_type = create(:assignment_type, course: @course)
        timestamp = Time.new
        assignment = create(:assignment, assignment_type: assignment_type, due_at: timestamp)
        @course.assignments << assignment

        get :feed, :format => :ics
        assigns(:assignments).should eq([assignment])
        response.body.should include(assignment.name)
        response.body.should include(timestamp.strftime("%Y%m%d"))
      end
    end

    describe "protected routes" do
      [
        :new,
        :copy,
        :create,
        :sort

      ].each do |route|
        it "#{route} redirects to root" do
          (get route).should redirect_to(:root)
        end
      end
    end

    describe "protected routes requiring id in params" do
      [
        :edit,
        :update,
        :destroy,
        :export_grades,
        :email_based_grade_import,
        :name_based_grade_import,
        :username_based_grade_import,
        :update_rubrics,
        :rubric_grades_review

      ].each do |route|
        it "#{route} redirects to root" do
          (get route, {:id => "1"}).should redirect_to(:root)
        end
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
      it "returns assignments for the current course" do
        assignment_type = create(:assignment_type, course: @course)
        assignment = create(:assignment, assignment_type: assignment_type)
        @course.assignments << assignment

        get :index
        assigns(:title).should eq("assignments")
        assigns(:assignment_types).should eq([assignment_type])
        assigns(:assignments).should eq([assignment])
      end
    end

    describe "GET index" do
      pending
    end
    describe "GET settings" do
      pending
    end
    describe "GET show" do
      pending
    end
    describe "GET guidelines" do
      pending
    end
    describe "GET rules" do
      pending
    end
    describe "GET new" do
      pending
    end
    describe "GET edit" do
      pending
    end
    describe "GET copy" do
      pending
    end
    describe "GET create" do
      pending
    end
    describe "GET update" do
      pending
    end
    describe "GET sort" do
      pending
    end
    describe "GET update_rubrics" do
      pending
    end
    describe "GET rubric_grades_review" do
      pending
    end
    describe "GET destroy" do
      pending
    end

    describe "GET feed" do
      it "returns a calendar event" do
        timestamp = Time.new
        assignment = create(:assignment, due_at: timestamp)
        @course.assignments << assignment

        get :feed, :format => :ics
        assigns(:assignments).should eq([assignment])
        response.body.should include(assignment.name)
        response.body.should include(timestamp.strftime("%Y%m%d"))
      end
    end

    describe "GET email_based_grade_import" do
      pending
    end
    describe "GET username_based_grade_import" do
      pending
    end
    describe "GET name_based_grade_import" do
      pending
    end
    describe "GET export_grades" do
      pending
    end
  end
end
