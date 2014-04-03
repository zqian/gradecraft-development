class TierSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :points
end
