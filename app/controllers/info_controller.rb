class InfoController < ApplicationController
  helper_method :sort_column, :sort_direction, :predictions

  before_filter :ensure_staff?, :except => [ :dashboard, :timeline_events ]

  # Displays instructor dashboard, with or without Team Challenge dates
  def dashboard
    @grade_scheme_elements = current_course.grade_scheme_elements
    #checking to see if the course uses the interactive timeline - if not sending students to their syllabus, and the staff to top 10
    if ! current_course.use_timeline?
      if current_user_is_student?
        redirect_to syllabus_path
      else
        redirect_to analytics_top_10_path
      end
    end
  end

  def timeline_events
    if current_course.team_challenges?
      @events = current_course.assignments.timelineable.with_due_date.to_a + current_course.challenges + current_course.events
    else
      @events = current_course.assignments.timelineable.with_due_date.to_a + current_course.events
    end
    render(:partial => 'info/timeline', :handlers => [:jbuilder], :formats => [:js])
  end



  def class_badges
    @title = "Awarded #{term_for :badges}"
  end

  # Displaying all ungraded, graded but unreleased, and in progress assignment submissions in the system
  def grading_status
    @title = "Grading Status"
    @ungraded_submissions = current_course.submissions.ungraded
    @unreleased_grades = current_course.grades.not_released
    @in_progress_grades = current_course.grades.in_progress
    @count_unreleased = @unreleased_grades.not_released.count
    @count_ungraded = @ungraded_submissions.count
    @count_in_progress = @in_progress_grades.count
    @badges = current_course.badges.includes(:tasks)
  end

  # Displaying all resubmisisons
  def resubmissions
    @title = "Resubmitted Assignments"
    @resubmissions = current_course.submissions.resubmitted
  end

  #grade index export
  def gradebook
    session[:return_to] = request.referer  
    GradebookExporter.perform_async(current_user.id, current_course.id)
    flash[:notice]="Your request to export the gradebook for \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to session[:return_to]
  end

  def final_grades
    respond_to do |format|
      format.csv { send_data current_course.final_grades_for_course(current_course) }
      format.xls { send_data current_course.final_grades_for_course(current_course).to_csv(col_sep: "\t") }
    end
  end

  #downloadable grades for course with  export
  def research_gradebook
    GradeExporter.perform_async(current_user.id, current_course.id)
    flash[:notice]="Your request to export grade data from course \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to courses_path
  end

  # Chart displaying all of the student weighting choices thus far
  def choices
    @title = "#{current_course.weight_term} Choices"
    @assignment_types = current_course.assignment_types
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?

    if @team
      students = current_course.students_being_graded_by_team(@team)
    else
      students = current_course.students_being_graded
    end

    @students = students
    @auditing = current_course.students_auditing
  end

  # Display all grades in the course in list form
  def all_grades
    @grades = current_course.grades.paginate(:page => params[:page], :per_page => 500)
  end

  #Course wide leaderboard - excludes auditors from view
  def leaderboard
    # before_filter :ensure_staff?
    @title = "Leaderboard"

    if team_leaderboard_active?
      # fetch user ids for all students in the active team
      @students = graded_students_in_current_course_for_active_team.order(leaderboard_sort_order)
    else
      # fetch user ids for all students in the course, regardless of team
      @students = graded_students_in_current_course.order(leaderboard_sort_order)
    end

    @student_ids = @students.collect {|s| s[:id] }
    @teams_by_student_id = teams_by_student_id
    @earned_badges_by_student_id = earned_badges_by_student_id
    @student_grade_schemes_by_id = course_grade_scheme_by_student_id
  end

  protected

  def course_grade_scheme_by_student_id
    @students.inject({}) do |memo, student|
      student_score = student.cached_score
      student_grade_scheme = nil
      course_grade_scheme_elements.each do |grade_scheme|
        if student_score >= grade_scheme.low_range and student_score <= grade_scheme.high_range
          student_grade_scheme = grade_scheme
          break
        end
      end
      memo.merge student[:id] => student_grade_scheme
    end
  end

  def course_grade_scheme_elements
    @course_grade_scheme_elements ||= current_course.grade_scheme_elements.order("low_range ASC")
  end

  def earned_badges_by_student_id
    @earned_badges_by_student_id ||= student_earned_badges_for_entire_course.inject({}) do |memo, earned_badge|
      student_id = earned_badge.student_id
      if memo[student_id]
        memo[student_id] << earned_badge
      else
        memo[student_id] = [earned_badge]
      end
      memo
    end
  end

  def teams_by_student_id
    @teams_by_student_id ||= team_memberships_for_course.inject({}) do |memo, tm|
      memo.merge tm.student_id => tm.team
    end
  end

  def team_memberships_for_course
    @team_memberships_for_course ||= TeamMembership.joins(:team)
      .where("teams.course_id = ?", current_course.id)
      .where(student_id: @student_ids)
      .includes(:team)
  end

  def course_teams
    @course_teams ||= Team.where(course: current_course)
      .joins(:team_memberships)
      .where("team_memberships.student_id in (?)", student_ids)
  end

  def course_team_membership_count
    TeamMembership.joins(:team).where("teams.course_id = ?", current_course[:id]).count
  end

  def student_earned_badges_for_entire_course
    @student_earned_badges ||= EarnedBadge.where(course: current_course).where("student_id in (?)", @student_ids).includes(:badge)
  end

  def leaderboard_sort_order
    "course_memberships.score DESC, users.last_name ASC, users.first_name ASC"
  end

  def fetch_active_team
    @team ||= Team.find params[:team_id]
  end

  def team_leaderboard_active?
    params[:team_id].present?
  end

  def graded_students_in_current_course
    if course_team_membership_count > 0
      User.graded_students_in_course_include_and_join_team(current_course.id)
    else
      User.graded_students_in_course(current_course.id)
    end
  end

  def graded_students_in_current_course_for_active_team
    if course_team_membership_count > 0
      User.graded_students_in_course_include_and_join_team(current_course.id)
        .where("team_memberships.team_id = ?", params[:team_id])
    else
      []
    end
  end
end
