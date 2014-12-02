class RubricGrade < ActiveRecord::Base
  belongs_to :submission
  belongs_to :metric
  belongs_to :tier
  belongs_to :student
  belongs_to :assignment

  attr_accessible :metric_name, :metric_description, :max_points, :tier_name,
    :tier_description, :points, :submission_id, :metric_id, :tier_id, :order,
    :student_id, :assignment_id

  validates :max_points, presence: true
  validates :metric_name, presence: true
  validates :order, presence: true
  validates :tier_name, presence: true
  validates :points, presence: true
  validates :submission_id, presence: true
  validates :submission_id, uniqueness: { scope: :metric_id }
end
