class ExistingTierSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points, :full_credit, :no_credit, :durable
end
