class MembershipCalculation < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  def is_team_member?
    return !(team_id.nil?)
  end

  def earned_badge_score # sum of all badges that you've earned that have points
  end

  def challenge_grade_score # sum of all challenge grades (same as assignments to grades) that belong to the team that you belong to
  end

  def in_progress_assignment_score # total possible score for all completed assignments for the student/user
  end

  def assignment_score # actual score on all completed assignments
  end

  def grade_score
  end

  def team_score
  end

  def weighted_assignment_score
  end
end
