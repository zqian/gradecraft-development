class CourseMembership < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  has_one :membership_calculation
  has_many :membership_scores

  attr_accessible :shared_badges, :auditing, :character_profile

  # sum of all grade scores
  # where the membership course is the same as the grade course
  # where student id on the grade is the same as the membership user_id

  def is_team_member?
    return !(team_id.nil?)
  end

  def released_grade_score 
    Grade
      .released
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(&:final_score)
  end

  def earned_badge_score # sum of all badges that you've earned that have points
  end

  def challenge_grade_score # sum of all challenge grades (same as assignments to grades) that belong to the team that you belong to
    ChallengeGrade
      .where(team_id: team_id)
      .where("teams.course_id = ?", 
      .sum(&:score)
      
  end

      
  end

  def in_progress_assignment_score # total possible score for all completed assignments for the student/user
  end

  def assignment_score # actual score on all completed assignments
  end

  # (SELECT COALESCE(sum(grades.score), (0)::bigint) AS "coalesce" FROM grades WHERE ((grades.course_id = m.course_id) AND (grades.student_id = m.user_id))) AS grade_score,
  def grade_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(&:final_score)
  end

  def team_score
    Grade
      .where(course_id: course.id)
      .where(student_id: user.id)
      .sum(&:final_score)
  end

  def weighted_assignment_score
  end


end
