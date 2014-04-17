class Rubric < ActiveRecord::Base
  belongs_to :assignment
  has_many :metrics
  has_many :rubric_grades

  validates :assignment, presence: true

  attr_accessible :assignment_id

  def max_tier_count
    metrics.inject([]) do |tier_counts, metric|
      tier_counts << metric.tiers.count
    end.max
  end
end
