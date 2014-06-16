class TierBadge < ActiveRecord::Base
  belongs_to :tier
  belongs_to :badge

  attr_accessible :tier_id, :badge_id
end
