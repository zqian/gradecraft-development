class ExistingTierSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points
end
