class MetricBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :metric

  attr_accessible :metric_id, :badge_id
end
