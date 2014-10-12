class TransferRoleToCourseMemberships < ActiveRecord::Migration

  def up
    User.all.each do |u|
      u.course_memberships.to_a.each {|cm| cm.update_attribute(:role, u.role)}
    end
  end

  def down
    User.all.each do |u|
      u.update_attribute(:role, u.course_memberships.where(course_id: u.default_course).first.role) unless u.course_memberships.empty?
    end
  end
end
