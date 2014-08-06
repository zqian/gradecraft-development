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

    SELECT m.id, m.id AS course_membership_id, m.course_id, m.user_id, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, earned_badges.updated_at)), (0)::double precision) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))))) AS earned_badges_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, submissions.updated_at)), (0)::double precision) AS "coalesce" FROM submissions WHERE ((submissions.course_id = m.course_id) AND (submissions.student_id = m.user_id))))) AS submissions_key, md5(pg_catalog.concat(m.course_id, m.user_id, (SELECT COALESCE(sum(date_part('epoch'::text, aw.updated_at)), (0)::double precision) AS "coalesce" FROM assignment_weights aw WHERE ((aw.student_id = m.user_id) AND (aw.course_id = aw.course_id))))) AS assignment_weights_key, (SELECT COALESCE(sum(a.point_total), (0)::bigint) AS "coalesce" FROM assignments a WHERE (a.course_id = m.course_id)) AS assignment_score,
    
    (SELECT COALESCE(sum(assignments.point_total), (0)::bigint) AS "coalesce" FROM assignments WHERE (((assignments.course_id = m.course_id) AND (m.user_id = m.user_id)) AND (EXISTS (SELECT 1 FROM released_grades WHERE ((released_grades.assignment_id = assignments.id) AND (released_grades.student_id = m.user_id)))))) AS in_progress_assignment_score,
    
    (SELECT COALESCE(sum(grades.score), (0)::bigint) AS "coalesce" FROM grades WHERE ((grades.course_id = m.course_id) AND (grades.student_id = m.user_id))) AS grade_score,
    
    
    
    (SELECT COALESCE(sum(earned_badges.score), (0)::bigint) AS "coalesce" FROM earned_badges WHERE ((earned_badges.course_id = m.course_id) AND (earned_badges.student_id = m.user_id))) AS earned_badge_score,
    
    (SELECT COALESCE(sum(challenge_grades.score), (0)::bigint) AS "coalesce" FROM (((challenge_grades JOIN challenges ON ((challenge_grades.challenge_id = challenges.id))) JOIN teams ON ((challenge_grades.team_id = teams.id))) JOIN team_memberships ON ((team_memberships.team_id = teams.id))) WHERE ((teams.course_id = m.course_id) AND (team_memberships.student_id = m.user_id))) AS challenge_grade_score,
    
    (SELECT teams.id FROM (teams JOIN team_memberships ON ((team_memberships.team_id = teams.id))) WHERE ((teams.course_id = m.course_id) AND (team_memberships.student_id = m.user_id)) ORDER BY team_memberships.updated_at DESC LIMIT 1) AS team_id, (SELECT sum(COALESCE(assignment_weights.point_total, assignments.point_total)) AS sum FROM (assignments LEFT JOIN assignment_weights ON (((assignments.id = assignment_weights.assignment_id) AND (assignment_weights.student_id = m.user_id)))) WHERE (assignments.course_id = m.course_id)) AS weighted_assignment_score,
    
    (SELECT count(*) AS count FROM assignment_weights WHERE (assignment_weights.student_id = m.user_id)) AS assignment_weight_count, cck.course_key, cck.assignments_key, cck.grades_key, cck.badges_key FROM (course_memberships m JOIN course_cache_keys cck ON ((m.course_id = cck.id)));

end
