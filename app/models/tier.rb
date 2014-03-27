class Tier < ActiveRecord::Base
  belongs_to :metric

  validates :points, presence: true
  validates :name, presence: true

  attr_accessible :name, :description, :points

end
