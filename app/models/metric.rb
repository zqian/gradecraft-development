class Metric < ActiveRecord::Base
  belongs_to :rubric
  has_many :tiers, dependent: :destroy
  attr_accessible :name, :max_points, :description, :order, :rubric_id

  after_create :generate_default_tiers

  validates :max_points, presence: true
  validates :name, presence: true
  validates :order, presence: true

  scope :ordered, lambda { order(:order) }

  def description_missing?
    description.nil? or description.blank?
  end

  protected

  def generate_default_tiers
    tiers.create name: "Full Credit", points: max_points, full_credit: true, durable: true
    tiers.create name: "No Credit", points: 0, no_credit: true, durable: true
  end
end
