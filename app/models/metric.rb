class Metric < ActiveRecord::Base
  belongs_to :rubric
  has_many :tiers, dependent: :destroy
  attr_accessible :name, :max_points, :description, :order

  validates :max_points, presence: true
  validates :name, presence: true
  validates :order, presence: true
end
