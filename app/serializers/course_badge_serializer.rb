class CourseBadgeSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :point_total, :icon, :multiple

  def multiple
    object.can_earn_multiple_times
  end

  def icon
    object.icon.url
  end
end
