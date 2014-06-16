class ExistingTierBadgeSerializer < ActiveModel::Serializer
  attributes :id, :tier_id, :badge_id
end
