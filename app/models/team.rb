class Team < ActiveRecord::Base
  attr_accessible :name, :course, :course_id, :student_ids, :score, :students, :leaders, :teams_leaderboard, :in_team_leaderboard, 
  :banner, :leader_ids, :badge_email_type

  validates_presence_of :course, :name

  #TODO: remove these callbacks 
  #Saving the team score if a challenge grade has been added
  #after_validation :cache_score
  #TODO: not sure why the save is called again, after_validation :cache_score already doing save_students
  #after_save :save_students


  #Teams belong to a single course
  belongs_to :course

  has_many :team_memberships
  has_many :students, :through => :team_memberships, :autosave => true
  has_many :team_leaderships
  has_many :leaders, :through => :team_leaderships

  #Teams design banners that they display on the leadboard
  mount_uploader :banner, ThumbnailUploader

  #Teams don't currently earn badges directly - but they are recognized for the badges their students earn
  has_many :earned_badges, :through => :students

  #Teams compete through challenges, which receive points through challenge_grades
  has_many :challenge_grades
  has_many :challenges, :through => :challenge_grades

  accepts_nested_attributes_for :team_memberships

  #Various ways to sort the display of teams
  scope :order_by_high_score, -> { order 'teams.score DESC' }
  scope :order_by_low_score, -> { order 'teams.score ASC' }
  scope :order_by_average_high_score, -> { order 'average_points DESC'}
  scope :alpha, -> { order 'teams.name ASC'}

  # DEPRECATED -- Assume Teams can have more than one leader. This should be removed
  # once we verify all uses are removed and new methods for cycling through team leaders
  # are in place.
  def team_leader
    leaders.first
  end

  #Sorting team's students by their score, currently only used for in team leaderboards
  def sorted_students
    students.sort_by{ |student| - student.cached_score_for_course(course) }
  end

  #Tallying how many students are on the team
  def member_count
    students.count
  end

  #Tallying how many badges the students on the team have earned total
  def badge_count
    earned_badges.count
  end

  #Calculating the average points amongst all students on the team
  def average_points
    total_score = 0
    students.each do |student|
      total_score += (student.assignment_scores_for_course(course) || 0 )
    end
    if member_count > 0
      average_points = total_score / member_count
    end
  end

  #Summing all of the points the team has earned across their challenges
  def challenge_grade_score
    challenge_grades.sum('score') || 0
  end

  def cache_score
    if course.team_score_average?
      self.score = average_points
    else
      self.score = challenge_grade_score
    end
  end

  private

  #Teams rack up points in two ways, which is used is determined by the instructor in the course settings.
  #The first way is that the team's score is the average of its students' scores, and challenge grades are
  #added directly into students' scores
  #The second way is that the teams compete in team challenges that earn the team points. At the end of the
  #semester these usually get added back into students' scores - this has not yet been built into GC.
  #def cache_score
    #if course.team_score_average?
      #save_students
      #self.score = average_points
    #else
      #self.score = challenge_grade_score
      #save_students
    #end
  #end

  #def save_students
    #students.each do |student|
      #student.cache_scores
    #end
  #end

end
