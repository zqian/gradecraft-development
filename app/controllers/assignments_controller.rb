class AssignmentsController < ApplicationController

  #before_filter :ensure_staff?, :except => [:feed, :show, :index]

  def index
    redirect_to syllabus_path if current_user_is_student?
    @title = "#{term_for :assignments}"
    @assignments = current_course.assignments.chronological.alphabetical
  end

  #Gives the instructor the chance to quickly check all assignment settings for the whole course
  def settings
    @title = "Review #{term_for :assignment} Settings"
    @assignments = current_course.assignments.chronological.alphabetical
  end

  def show
    @assignment = current_course.assignments.find(params[:id])
    @title = @assignment.name
    @groups = @assignment.groups
    
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
    if @team
      students = current_course.students_being_graded_by_team(@team)
    else
      students = current_course.students_being_graded
    end
    user_search_options = {}
    user_search_options['team_memberships.team_id'] = params[:team_id] if params[:team_id].present?
    @students = students

    @auditing = current_course.students_auditing.includes(:teams).where(user_search_options)
    @rubric = @assignment.fetch_or_create_rubric
    @metrics = @rubric.metrics
    @score_levels = @assignment.score_levels.order_by_value
    @course_badges = serialized_course_badges
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value
    @course_student_ids = current_course.students.map(&:id)

    # Data for displaying student grading distribution
    @submissions_count = @assignment.submissions.count
    @ungraded_submissions_count = @assignment.ungraded_submissions.count
    @ungraded_percentage = @ungraded_submissions_count / @submissions_count rescue 0
    @graded_count = @submissions_count - @ungraded_submissions_count

    if current_user_is_student?
      @grades_for_assignment = @assignment.grades_for_assignment(current_student)
      @rubric_grades = RubricGrade.joins("left outer join submissions on submissions.id = rubric_grades.submission_id").where("submissions.student_id =?", current_user[:id])
    end

    #used to display an alternate view of the same content
    render :detailed_grades if params[:detailed]
  end

  def rules
    @assignment = current_course.assignments.find(params[:id])
    @title = @assignment.name
  end

  def new
    @title = "Create a New #{term_for :assignment}"
    @assignment = current_course.assignments.new
  end

  def edit
    @assignment = current_course.assignments.find(params[:id])
    @title = "Editing #{@assignment.name}"
  end

  # Duplicate an assignment - important for super repetitive items like attendance and reading reactions
  def copy
    @assignment = current_course.assignments.find(params[:id])
    new_assignment = @assignment.dup
    new_assignment.save
    redirect_to @assignment.assignment_type
  end

  def create
    @assignment = current_course.assignments.new(params[:assignment])
    @title = "Create a New #{term_for :assignment}"
    @assignment.assignment_type = current_course.assignment_types.find_by_id(params[:assignment_type_id])
    respond_to do |format|
      self.check_uploads
      @assignment.save
      if @assignment.save
        set_assignment_weights
        format.html { respond_with @assignment, notice: "#{(term_for :assignment).titleize}  #{@assignment.name} successfully created" }
      else
        format.html {render :action => "new", :group => @group }
      end
    end
  end

  def check_uploads
    if params[:assignment][:assignment_files_attributes]["0"][:filepath].empty?
      params[:assignment].delete(:assignment_files_attributes)
      @assignment.assignment_files.destroy_all
    end
  end

  def update
    @assignment = current_course.assignments.includes(:assignment_score_levels).find(params[:id])
    @title = "Edit #{term_for :assignment}"
    respond_to do |format|
      self.check_uploads
      @assignment.assign_attributes(params[:assignment])
      if @assignment.save
        set_assignment_weights
        format.html { respond_with @assignment, notice: "#{(term_for :assignment).titleize}  #{@assignment.name} successfully updated" }
      else
        format.html {render :action => "new", :group => @group }
      end
    end
  end

  def destroy
    @assignment = current_course.assignments.find(params[:id])
    @name = @assignment.name
    @assignment.destroy
    redirect_to assignments_url, notice: "#{(term_for :assignment).titleize} #{@name} successfully deleted"
  end

  # Calendar feed of assignments
  def feed
    @assignments = current_course.assignments
    respond_with @assignments.with_due_date do |format|
      format.ics do
        render :text => CalendarBuilder.new(:assignments => @assignments.with_due_date ).to_ics, :content_type => 'text/calendar'
      end
    end
  end

  # Export an example for grade imports
  def email_based_grade_import
    @assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
      format.csv { send_data @assignment.email_based_grade_import(@assignment) }
      format.xls { send_data @assignment.to_csv(col_sep: "\t") }
    end
  end

  def username_based_grade_import
    @assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
      format.csv { send_data @assignment.username_based_grade_import(@assignment) }
      format.xls { send_data @assignment.to_csv(col_sep: "\t") }
    end
  end

  def name_based_grade_import
    @assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
      format.csv { send_data @assignment.name_based_grade_import(@assignment) }
      format.xls { send_data @assignment.to_csv(col_sep: "\t") }
    end
  end

  # Exporting the grades for a single assignment
  def export_grades
    @assignment = current_course.assignments.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @assignment }
      format.csv { send_data @assignment.gradebook_for_assignment(@assignment) }
      format.xls { send_data @assignment.to_csv(col_sep: "\t") }
    end
  end

  private

  def find_or_create_assignment_rubric
    @assignment.rubric || Rubric.create(assignment_id: @assignment[:id])
  end

  def assignment_params
    params.require(:assignment).permit(:assignment_rubrics_attributes => [:id, :rubric_id, :_destroy])
  end

  def set_assignment_weights
    return unless @assignment.student_weightable?
    @assignment.weights = current_course.students.map do |student|
      assignment_weight = @assignment.weights.where(student: student).first || @assignment.weights.new(student: student)
      assignment_weight.weight = @assignment.assignment_type.weight_for_student(student)
      assignment_weight
    end
    @assignment.save
  end

  def serialized_course_badges
    ActiveModel::ArraySerializer.new(course_badges, each_serializer: CourseBadgeSerializer).to_json
  end

  def course_badges
    @course_badges ||= @assignment.course.badges.visible
  end

  def existing_metrics_as_json
    ActiveModel::ArraySerializer.new(rubric_metrics_with_tiers, each_serializer: ExistingMetricSerializer).to_json
  end

  def rubric_metrics_with_tiers
    @rubric.metrics.order(:order).includes(:tiers)
  end

end
