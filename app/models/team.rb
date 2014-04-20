class Team < ActiveRecord::Base
  attr_accessible :name, :course, :course_id, :student_ids, :score, :students, :teams_leaderboard, :in_team_leaderboard, :banner

  belongs_to :course

  has_many :team_memberships
  has_many :students, :through => :team_memberships

  mount_uploader :banner, ThumbnailUploader

  has_many :earned_badges, :through => :students

  has_many :challenge_grades
  has_many :challenges, :through => :challenge_grades

  after_validation :cache_score

  validates_presence_of :course, :name

  accepts_nested_attributes_for :team_memberships

  scope :alpha, -> { order 'name ASC' }
  scope :order_by_high_score, -> { order 'teams.score DESC' }
  scope :order_by_low_score, -> { order 'teams.score ASC' }

  def team_leader
    students.gsis.first
  end

  def sorted_students
    students.sort_by{ |student| - student.cached_score_for_course(course) }
  end

  def member_count
    students.count
  end

  def badge_count
    earned_badges.count
  end

  #Calculating the average 
  def average_points
    total_score = 0
    students.each do |student|
      total_score += (student.cached_score_for_course(course) || 0 )
    end
    if member_count > 0
      average_points = total_score / member_count
    end
  end

  #Summing all of the points the team has earned across their challenges
  def challenge_grade_score
    challenge_grades.sum('score') || 0
  end

  private

  #Teams rack up points in two ways, which is used is determined by the instructor in the course settings.
  #The first way is that the team's score is the average of its students' scores
  #The second way is that the teams compete in team challenges that earn the team points. At the end of the 
  #semester these usually get added back into students' scores - this has not yet been built into GC.
  def cache_score
    if self.course.team_score_average?
      if self.score_changed?
        self.score = average_points
      end
    else
      self.score = challenge_grade_score
    end
  end

  def cache_user_scores
    if self.course.team_score_average?
      students.save
    end
  end
end