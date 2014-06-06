class MetricBadge < ActiveRecord::Base
  belongs_to :badge
  belongs_to :metric
end
