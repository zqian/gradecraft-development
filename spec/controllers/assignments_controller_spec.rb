require 'spec_helper'

describe AssignmentsController do

  context "as a student" do
    before do
      @course = create(:course_accepting_groups)
      @student = create(:user)
      @student.courses << @course
      login_user(@student)
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
        group = create(:group, course: @course)
        group.assignments << @assignment
        get :show, {:id => @assignment.id}
        assigns(:groups).should eq([group])
      end

      it "assigns assignment_grades_by_student_id" do
        grade = create(:grade, assignment: @assignment, student: @student)
        get :show, {:id => @assignment.id}
        assigns(:assignment_grades_by_student_id).should eq({@student.id => grade})
      end

      describe "with team id in params" do
        it "assigns team and students for team" do
          other_student = create(:user) # verify only students on team assigned as @students
          other_student.courses << @course
          team = create(:team, course: @course)
          team.students << @student

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:team).should eq(team)
          assigns(:students).should eq([@student])
        end

        it "assigns all team students auditing as auditing" do
          other_student = create(:user) # verify only auditing students on team assigned as @auditing
          other_student.courses << @course
          team = create(:team, course: @course)
          team.students << @student
          @student.course_memberships.first.update(auditing: true)
          other_student.course_memberships.first.update(auditing: true)

          get :show, {:id => @assignment.id, :team_id => team.id}
          assigns(:auditing).should eq([@student])
        end
      end

      describe "with no team id in params" do
        it "assigns all students if no team supplied" do
          other_student = create(:user) # verify non-team members also assigned as @students
          other_student.courses << @course
          team = create(:team, course: @course)
          team.students << @student

          get :show, {:id => @assignment.id}
          assigns(:students).should include(@student)
          assigns(:students).should include(other_student)
        end

        it "assigns all auditing students as auditing" do
          @student.course_memberships.first.update(auditing: true)
          get :show, {:id => @assignment.id}
          assigns(:auditing).should eq([@student])
        end
      end

      it "assigns the rubric as rubric" do
        rubric = create(:rubric_with_metrics, assignment: @assignment)
        get :show, {:id => @assignment.id}
        assigns(:rubric).should eq(rubric)
        assigns(:metrics).should eq(rubric.metrics)
      end

      it "assigns course badges as JSON using CourseBadgeSerializer" do
        badge = create(:badge, course: @course)
        get :show, {:id => @assignment.id}
        assigns(:course_badges).should eq(ActiveModel::ArraySerializer.new([badge], each_serializer: CourseBadgeSerializer).to_json)
      end

      it "assigns assignment score levels ordered by value" do
        assignment_score_level_second = create(:assignment_score_level, assignment: @assignment, value: "1000")
        assignment_score_level_first = create(:assignment_score_level, assignment: @assignment, value: "100")
        get :show, {:id => @assignment.id}
        assigns(:assignment_score_levels).should eq([assignment_score_level_first,assignment_score_level_second])
      end

      it "assigns student ids" do
        get :show, {:id => @assignment.id}
        assigns(:course_student_ids).should eq([@student.id])
      end

      it "assigns data for displaying student grading distribution" do
        pending "need to create a scored grade"
        ungraded_submission = create(:submission, assignment: @assignment)
        student_submission = create(:graded_submission, assignment: @assignment, student: @student)
        @assignment.submissions << [student_submission, ungraded_submission]
        get :show, {:id => @assignment.id}
        assigns(:submissions_count).should eq(2)
        assigns(:ungraded_submissions_count).should eq(1)
        assigns(:ungraded_percentage).should eq(1/2)
        assigns(:graded_count).should eq(1)
      end

      # GET show, student specific assignments:

      it "assigns grades for assignment" do
        grade = create(:grade, student: @student, assignment: @assignment)
        get :show, {:id => @assignment.id}
        assigns(:grades_for_assignment).should eq(@assignment.grades_for_assignment(@student))
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

      it "assigns group if student is in a group" do
        @assignment.update(grade_scope: "Group")
        group = create(:group, course: @course)
        group.assignments << @assignment
        group.students << @student
        get :show, {:id => @assignment.id}
        assigns(:group).should eq(group)
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
      @professor = create(:user)
      @professor.courses << @course
      @membership = CourseMembership.where(user: @professor, course: @course).first.update(role: "professor")
      login_user(@professor)
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
