class TierBadge < ActiveRecord::Base
  belongs_to :tier
  belongs_to :badge
end
