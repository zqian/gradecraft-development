class ChallengeScoreLevel < ActiveRecord::Base
  belongs_to :challenge

  attr_accessible :name, :value, :challenge_id

  validates_presence_of :value, :name
  scope :order_by_value, -> { order 'value DESC' }

  def formatted_name
    "#{name} - #{value} points"
  end

end