class SharedEarnedBadge < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  mount_uploader :icon, SharedBadgeIconUploader

  def self.earned_badges
    where("SELECT course_memberships.course_id, (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS student_name, users.id AS user_id, earned_badges.id, badges.icon, badges.name, badges.id AS badge_id FROM (((course_memberships JOIN users ON ((users.id = course_memberships.user_id))) JOIN earned_badges ON ((earned_badges.student_id = users.id))) JOIN badges ON ((badges.id = earned_badges.badge_id))) WHERE (((course_memberships.shared_badges = true) AND (badges.icon IS NOT NULL)) AND (earned_badges.shared = true))")
  end

  def self.badges_for_course
    where("SELECT course_memberships.course_id, (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS student_name, users.id AS user_id, earned_badges.id, badges.icon, badges.name, badges.id AS badge_id FROM (((course_memberships JOIN users ON ((users.id = course_memberships.user_id))) JOIN earned_badges ON ((earned_badges.student_id = users.id))) JOIN badges ON ((badges.id = earned_badges.badge_id))) WHERE (((course_memberships.shared_badges = true) AND (badges.icon IS NOT NULL)) AND (earned_badges.shared = true))")
  end
end
