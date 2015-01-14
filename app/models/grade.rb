class Grade < ActiveRecord::Base
  include Canable::Ables

  attr_accessible :raw_score, :predicted_score, :final_score, :feedback, :assignment,
    :assignment_id, :status, :attempted, :student, :student_id, :submission, :submission_id, :released,
    :group, :group_id, :group_type, :task, :task_id, :graded_by_id, :team_id, :grade_file_ids,
    :grade_files_attributes, :grade_file, :assignments_attributes, :point_total, :assignment_type_id, :course_id,
    :instructor_modified

  STATUSES= ["In Progress", "Graded", "Released"]

  belongs_to :course
  belongs_to :assignment, touch: true
  belongs_to :assignment_type
  belongs_to :student, :class_name => 'User', touch: true
  belongs_to :team, touch: true
  belongs_to :submission # Optional
  belongs_to :task # Optional
  belongs_to :group, :polymorphic => true # Optional
  belongs_to :graded_by, class_name: 'User'

  has_many :earned_badges, :dependent => :destroy

  has_many :badges, :through => :earned_badges
  accepts_nested_attributes_for :earned_badges

  before_validation :cache_associations
  before_save :cache_score_and_point_total

  has_many :grade_files, :dependent => :destroy
  accepts_nested_attributes_for :grade_files

  validates_presence_of :assignment, :assignment_type, :course, :student
  validates :assignment_id, :uniqueness => {:scope => :student_id}

  delegate :name, :description, :due_at, :assignment_type, :to => :assignment

  before_save :clean_html
  #TODO: removed these callback check with cait
  after_save :update_scores
  after_create :update_scores
  #after_destroy :save_student, :save_team
  #TODO: called only destroy callback since worker is executing cache_student_and_team_scores
  after_destroy :cache_student_and_team_scores

  scope :completion, -> { where(order: "assignments.due_at ASC", :joins => :assignment) }
  scope :graded, -> { where('status = ?', 'Graded') }
  scope :in_progress, -> { where('status = ?', 'In Progress') }
  scope :released, -> { joins(:assignment).where("status = 'Released' OR (status = 'Graded' AND NOT assignments.release_necessary)") }
  scope :graded_or_released, -> { where("status = 'Graded' OR status = 'Released'")}
  scope :not_released, -> { joins(:assignment).where("status = 'Graded' AND assignments.release_necessary")}

  validates_numericality_of :raw_score, integer_only: true

  def self.score
    pluck('COALESCE(SUM(grades.score), 0)').first
  end

  def self.predicted_points
    #Only return back the total predicted points for a user, not including points they have been scored on
    scoped.not_released.pluck('COALESCE(SUM(grades.predicted_score), 0)').first
  end

  def self.assignment_scores
    pluck('grades.assignment_id, grades.score')
  end

  def self.assignment_type_scores
    group('grades.assignment_type_id').pluck('grades.assignment_type_id, COALESCE(SUM(grades.score), 0)')
  end

  def is_graded?
    self.status == 'Graded'
  end

  def in_progress?
    self.status == 'In Progress'
  end

  # DEPRECATED
  # def self.excluding_auditing_students
  #   joins('INNER JOIN course_memberships ON (grades.student_id = course_memberships.user_id AND grades.course_id = course_memberships.course_id AND course_memberships.auditing = ?)', false)
  # end

  def score
    if student.weighted_assignments?
      final_score || (raw_score * assignment_weight).round
    else
      final_score || raw_score
    end
  end

  def predicted_score
    self[:predicted_score] || 0
  end

  def point_total
    assignment.point_total_for_student(student)
  end

  def assignment_weight
    assignment.weight_for_student(student)
  end

  def has_feedback?
    feedback != "" && feedback != nil
  end

  def is_released?
    status == 'Released' || (status = 'Graded' && ! assignment.release_necessary)
  end

  def is_graded_or_released?
    is_graded? || is_released?
  end

  def status_is_graded_or_released?
    self.status == "Graded" || self.status == "Released"
  end
  alias_method :graded_or_released?, :status_is_graded_or_released?

  #Canable Permissions
  def updatable_by?(user)
    creator == user
  end

  def creatable_by?(user)
    student_id == user.id
  end

  def viewable_by?(user)
    student_id == user.id
  end

  def self.to_csv(options = {})
    #CSV.generate(options) do |csv|
      #csv << ["First Name", "Last Name", "Score", "Grade"]
      #students.each do |user|
        #csv << [user.first_name, user.last_name]
        #, user.earned_grades(course), user.grade_level(course)]
      #end
    #end
  end

  def cache_student_and_team_scores
    self.student.cache_course_score(self.course.id)
    if self.course.has_teams? && self.student.team_for_course(self.course).present?
      self.student.team_for_course(self.course).cache_score
    end
  end


  private

  def clean_html
    self.feedback = Sanitize.clean(feedback, Sanitize::Config::BASIC)
  end

  def save_student
    if self.raw_score_changed? || self.status_changed?
      student.save
    end
  end

  def save_team
    if course.has_teams? && student.team_for_course(course).present?
      student.team_for_course(course).save
    end
  end

  def cache_score_and_point_total
    self.score = score
    self.point_total = point_total
  end

  def cache_associations
    self.student_id ||= submission.try(:student_id)
    self.task_id ||= submission.try(:task_id)
    self.assignment_id ||= submission.try(:assignment_id) || task.try(:assignment_id)
    self.assignment_type_id ||= assignment.try(:assignment_type_id)
    self.course_id ||= assignment.try(:course_id)
    self.team_id ||= student.team_for_course(course).try(:id)
  end

  def update_scores
     GradeUpdater.perform_async([self.id])
  end

end
