class ExistingMetricSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :max_points, :rubric_id, :order
  has_many :tiers, serializer: ExistingTierSerializer
end
