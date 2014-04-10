class Metric < ActiveRecord::Base
  belongs_to :rubric
  has_many :tiers, dependent: :destroy
  attr_accessible :name, :max_points, :description, :order, :rubric_id

  validates :max_points, presence: true
  validates :name, presence: true
  validates :order, presence: true

  scope :ordered, lambda { order(:order) }

  def description_missing?
    description.nil? or description.blank?
  end
end
