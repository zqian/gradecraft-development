class ExistingTierSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points, :full_credit, :no_credit, :durable
  has_many :tier_badges
end
