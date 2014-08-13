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

  #    (SELECT COALESCE(sum(earned_badges.score), (0)::bigint) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))) AS earned_badge_score,
  def earned_badge_score # sum of all badges that you've earned that have points
    EarnedBadge
      .where(student_id: user.id)
      .where(course_id: course.id)
      .sum(&:score)
  end

  #    (SELECT COALESCE(sum(challenge_grades.score), (0)::bigint) AS "coalesce" FROM (((challenge_grades JOIN challenges ON ((challenge_grades.challenge_id = challenges.id))) JOIN teams ON ((challenge_grades.team_id = teams.id))) JOIN team_memberships ON ((team_memberships.team_id = teams.id))) WHERE ((teams.course_id = m.course_id) AND (team_memberships.student_id = m.user_id))) AS challenge_grade_score,
  def challenge_grade_score # sum of all challenge grades (same as assignments to grades) that belong to the team that you belong to
    ChallengeGrade
      .where(team_id: team_id)
      .where("teams.course_id = ?", course.id)
      .sum(&:score)
      
  end

  #    (SELECT COALESCE(sum(assignments.point_total), (0)::bigint) AS "coalesce" FROM assignments
  #    WHERE (((assignments.course_id = m.course_id)
  #    AND (m.user_id = m.user_id)) AND (EXISTS (SELECT 1 FROM released_grades
  #    WHERE ((released_grades.assignment_id = assignments.id)
  #    AND (released_grades.student_id = m.user_id))))))
  #    AS in_progress_assignment_score,
  def in_progress_assignment_score # total possible score for all completed assignments for the student/user
    Assignment
      .where(student_id: user.id)
      .where(course_id: course.id)
      .released # scope in Assignment
      .sum(&:score)
  end

  #    SELECT m.id, m.id AS course_membership_id, m.course_id, m.user_id, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, earned_badges.updated_at)), (0)::double precision) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))))) AS earned_badges_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, submissions.updated_at)), (0)::double precision) AS "coalesce"
  #    
  #    FROM submissions
  #    WHERE ((submissions.course_id = m.course_id) AND (submissions.student_id = m.user_id))))) AS submissions_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, aw.updated_at)), (0)::double precision) AS "coalesce" FROM assignment_weights aw WHERE ((aw.student_id = m.user_id) AND (aw.course_id = aw.course_id))))) AS assignment_weights_key, 
  #    (SELECT COALESCE(sum(a.point_total), (0)::bigint) AS "coalesce" FROM assignments a WHERE (a.course_id = m.course_id)) AS assignment_score,
  #    earned badges
  #    submissions
  # 
  # combination of grades for completed assignments, including assignment weights where they exist
  #
  def assignment_score # actual score on all completed assignments
    Submission
      .includes(:grade, :rubric_grades, assignment: :assignment_weights)
      .where(course_id: course_id)
      .where(student_id: user.id)
      .inject(0) do |memo, submission|
        memo << submission.assignment_weight ? submission.assignment_weight.point_total : submission.assignment.point_total
      end
  end

  def test_assignment_score
    Submission.includes(:grade, :rubric_grades, assignment: [:assignment_weights])
      .where(course_id: 1)
      .where(student_id: 52)
      .inject(0) do |memo, submission|
        memo << submission.assignment.assignment_weight ? submission.assignment_weight.point_total : submission.assignment.point_total
      end
  end

  def sql_assignment_score
    ActiveRecord::Base.connection.execute()
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

  #    (SELECT sum(COALESCE(assignment_weights.point_total, assignments.point_total))
  #    AS sum FROM (assignments 
  #    WHERE (assignments.course_id = m.course_id))
  #    AS weighted_assignment_score,
  #
  #    Total possible points for all assignments
  def weighted_assignment_score
    Assignment
      .joins("LEFT JOIN assignment_weights ON (((assignments.id = assignment_weights.assignment_id) AND (assignment_weights.student_id = ?)))", user.id)
      .where(course_id: course.id)
      .sum(&:point_total)
  end

#    (SELECT count(*) AS count FROM assignment_weights WHERE (assignment_weights.student_id = m.user_id)) AS assignment_weight_count, cck.course_key, cck.assignments_key, cck.grades_key, cck.badges_key FROM (course_memberships m JOIN course_cache_keys cck ON ((m.course_id = cck.id)));

  protected
  def student_id
    @student_id ||= user.id
  end
end
