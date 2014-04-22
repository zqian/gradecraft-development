class Tier < ActiveRecord::Base
  belongs_to :metric

  validates :points, presence: true, numericality: {greater_than_or_equal_to: 0}
  validates :name, presence: true

  attr_accessible :name, :description, :points, :metric_id, :durable, :full_credit, :no_credit, :sort_order

end
