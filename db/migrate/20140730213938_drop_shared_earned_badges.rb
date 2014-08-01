class DropSharedEarnedBadges < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      DROP VIEW shared_earned_badges
    SQL
  end
  def self.down
    execute <<-SQL
      CREATE VIEW shared_earned_badges AS
        SELECT course_memberships.course_id, (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS student_name, users.id AS user_id, earned_badges.id, badges.icon, badges.name, badges.id AS badge_id FROM (((course_memberships JOIN users ON ((users.id = course_memberships.user_id))) JOIN earned_badges ON ((earned_badges.student_id = users.id))) JOIN badges ON ((badges.id = earned_badges.badge_id))) WHERE (((course_memberships.shared_badges = true) AND (badges.icon IS NOT NULL)) AND (earned_badges.shared = true));
    SQL
  end
end
