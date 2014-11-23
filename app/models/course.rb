class Course < ActiveRecord::Base

  # Note: we are setting the role scopes as instance methods,
  # not class methods, so that they are limited to the users
  # of the current course
  ROLES = %w(student professor gsi admin)

  ROLES.each do |role|
    define_method(role.pluralize) do
      User.with_role_in_course(role, self)
    end
  end

  def students_being_graded
    User.students_being_graded(self)
  end

  def students_being_graded_by_team(team)
    User.students_being_graded(self,team)
  end

  def students_auditing
    User.students_auditing(self)
  end

  def students_auditing_by_team(team)
    User.students_auditing(self,team)
  end

  attr_accessible :courseno, :name,
    :semester, :year, :badge_setting, :team_setting, :team_term, :user_term,
    :user_id, :course_id, :homepage_message, :group_setting,
    :total_assignment_weight, :assignment_weight_close_at, :team_roles,
    :section_leader_term, :group_term, :assignment_weight_type,
    :has_submissions, :teams_visible, :badge_use_scope,
    :weight_term, :badges_value, :predictor_setting, :max_group_size,
    :min_group_size, :shared_badges, :graph_display, :max_assignment_weight,
    :assignments, :default_assignment_weight, :accepts_submissions,
    :tagline, :academic_history_visible, :office, :phone, :class_email,
    :twitter_handle, :twitter_hashtag, :location, :office_hours, :meeting_times,
    :use_timeline, :media_file, :media_credit, :media_caption, :assignment_term,
    :challenge_term, :badge_term, :grading_philosophy, :team_score_average,
    :team_challenges, :team_leader_term, :max_assignment_types_weighted,
    :point_total, :in_team_leaderboard, :grade_scheme_elements_attributes,
    :add_team_score_to_student, :status, :assignments_attributes

  with_options :dependent => :destroy do |c|
    c.has_many :assignment_types
    c.has_many :assignments
    c.has_many :assignment_weights
    c.has_many :badges
    c.has_many :challenges
    c.has_many :challenge_grades, :through => :challenges
    c.has_many :earned_badges
    c.has_many :grade_scheme_elements
    c.has_many :grades
    c.has_many :groups
    c.has_many :group_memberships
    c.has_many :submissions
    c.has_many :teams
    c.has_many :course_memberships
  end

  has_many :users, :through => :course_memberships
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :assignments


  accepts_nested_attributes_for :grade_scheme_elements, allow_destroy: true

  validates_presence_of :name, :courseno
  validates_numericality_of :max_group_size, :allow_blank => true, :greater_than_or_equal_to => 1
  validates_numericality_of :min_group_size, :allow_blank => true, :greater_than_or_equal_to => 1
  validates_numericality_of :total_assignment_weight, :allow_blank => true
  validates_numericality_of :max_assignment_weight, :allow_blank => true
  validates_numericality_of :max_assignment_types_weighted, :allow_blank => true
  validates_numericality_of :default_assignment_weight, :allow_blank => true
  validates_numericality_of :point_total, :allow_blank => true

  validates_format_of :twitter_hashtag, :with => /\A[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*\z/, :allow_blank => true, :length   => { :within => 3..20 }
  validate :max_more_than_min

  def user_term
    super.presence || 'Player'
  end

  def team_term
    super.presence || 'Team'
  end

  def group_term
    super.presence || 'Group'
  end

  def team_leader_term
    super.presence || 'Team Leader'
  end

  def weight_term
    super.presence || 'Multiplier'
  end

  def badge_term
    super.presence || 'Badge'
  end

  def assignment_term
    super.presence || 'Assignment'
  end

  def challenge_term
    super.presence || 'Challenge'
  end

  def has_teams?
    team_setting == true
  end

  def has_team_challenges?
    team_challenges == true
  end

  def graph_display?
    graph_display == true
  end

  def teams_visible?
    teams_visible == true
  end

  def in_team_leaderboard?
    in_team_leaderboard == true
  end

  def has_badges?
    badge_setting == true
  end

  def valuable_badges?
    badges_value == true
  end

  def has_groups?
    group_setting == true
  end

  def shared_badges?
    shared_badges == true
  end

  def formatted_tagline
    if tagline.present?
      tagline
    else
      " "
    end
  end

  #total number of points 'available' in the course - sometimes set by an instructor as a cap, sometimes just the sum of all assignments
  def total_points
    point_total || assignments.point_total
  end

  def active?
    status == true
  end

  def student_weighted?
    total_assignment_weight.to_i > 0
  end

  def assignment_weight_open?
    assignment_weight_close_at.nil? || assignment_weight_close_at > Time.now
  end

  def team_roles?
    team_roles == true
  end

  def has_submissions?
    accepts_submissions == true
  end

  def grade_level_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('level').first
  end

  def grade_letter_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).pluck('letter').first
  end

  def element_for_score(score)
    grade_scheme_elements.where('low_range <= ? AND high_range >= ?', score, score).first
  end

  def membership_for_student(student)
    course_memberships.detect { |m| m.user_id == student.id }
  end

  def assignment_weight_for_student(student)
    student.assignment_weights.pluck('weight').sum
  end

  def assignment_weight_spent_for_student(student)
    assignment_weight_for_student(student) >= total_assignment_weight.to_i
  end

  def score_for_student(student)
    course_memberships.where(:user_id => student).first.score
  end

  #Descriptive stats of the grades
  def minimum_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").minimum('score')
  end

  def maximum_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").maximum('score')
  end

  def average_course_score
    CourseMembership.where(:course => self, :auditing => false, :role => "student").average('score').to_i
  end
  
  def student_count
    students.count
  end

  def graded_student_count
    students_being_graded.count
  end

  def professor
    course_memberships.where(:role => "professor").first.user if course_memberships.where(:role => "professor").first.present?
  end

  #final grades - total score + grade earned in course
  def final_grades_for_course(course, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score", "Grade" ]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.email, student.cached_score_for_course(course), student.grade_letter_for_course(course)]
      end
    end
  end

  #gradebook spreadsheet export for course
  def gradebook_for_course(course)
    CSV.generate do |csv|
      assignment_names = []
      assignment_names << "First Name"
      assignment_names << "Last Name"
      assignment_names << "Email"
      course.assignments.chronological.alphabetical.each do |a|
        assignment_names << a.name
      end
      csv << assignment_names
      course.students.each do |student|
        student_data = []
        student_data << [student.first_name, student.last_name, student.email, student.team_for_course(course).try(:name)]

        csv << student_data
      end
    end
  end

  #raw points gradebook spreadsheet export for course - used in the event of multipliers
  def raw_points_gradebook_for_course(course, options = {})
    CSV.generate(options) do |csv|
      csv << ["First Name", "Last Name", "Email", "Score", "Grade" ]
      course.students.each do |student|
        csv << [student.first_name, student.last_name, student.email, student.cached_score_for_course(course), student.grade_letter_for_course(course)]
      end
    end
  end

  def research_grades_for_course(course, options = {})
    CSV.generate(options) do |csv|
      csv << ["Course ID", "Uniqname", "First Name", "Last Name", "GradeCraft ID", "Assignment Name", "Assignment ID", "Assignment Type", "Assignment Type Id", "Score", "Assignment Point Total", "Multiplied Score", "Predicted Score", "Text Feedback", "Submission ID", "Submission Creation Date", "Submission Updated Date", "Graded By", "Created At", "Updated At"]
      course.grades.each do |grade|
        csv << [grade.course.id, grade.student.username, grade.student.first_name, grade.student.last_name, grade.student_id, grade.assignment.name, grade.assignment.id, grade.assignment.assignment_type.name, grade.assignment.assignment_type_id, grade.raw_score, grade.point_total, grade.score, grade.predicted_score, grade.feedback, grade.submission_id, grade.submission.try(:created_at), grade.submission.try(:updated_at), grade.graded_by_id, grade.created_at, grade.updated_at]
      end
    end
  end

  def assignments_for_course
    CSV.generate do |csv|
      csv << ["Course Id", "Assignment ID", "Assignment Name", "Assignment Type ID", "Assignment Type Name", "Point Total", "Description", "Due at", "Open At", "Accepted Until", "Student Logged", "Submissions", "Predictor Display"]
      self.assignments.each do |assignment|
        csv << [assignment.course_id, assignment.id, assignment.name, assignment.assignment_type_id, assignment.assignment_type.name, assignment.point_total, assignment.description, assignment.due_at, assignment.open_at, assignment.accepts_submissions_until, assignment.student_logged, assignment.accepts_submissions, assignment.points_predictor_display]
      end
    end
  end

  def assignment_weighting_choices_for_course
    CSV.generate do |csv|
      csv << ["ID", "Course Id", "Assignment ID", "Assignment Name", "Assignment Type ID", "Assignment Type Name", "Student ID", "Student First Name", "Student Last Name", "Username", "Assignment Weight", "Created At", "Updated At"]
      self.assignment_weights.each do |aw|
        csv << [aw.id, aw.course_id, aw.assignment_id, aw.assignment.name, aw.assignment_type_id, aw.assignment_type.name, aw.student_id, aw.student.first_name, aw.student.last_name, aw.student.username, aw.weight, aw.created_at, aw.updated_at ]
      end
    end
  end


  #badges
  def course_badge_count
   badges.count
  end

  def awarded_course_badge_count
   earned_badges.count
  end

  def max_more_than_min
    if (max_group_size? && min_group_size?) && (max_group_size < min_group_size)
      errors.add :base, 'Maximum group size must be greater than minimum group size.'
    end
  end

end
