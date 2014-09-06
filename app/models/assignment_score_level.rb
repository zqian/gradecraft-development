class AssignmentScoreLevel < ActiveRecord::Base
  belongs_to :assignment

  attr_accessible :name, :value, :assignment_id

  validates_presence_of :value, :name, :assignment_id
  scope :order_by_value, -> { order 'value DESC' }

  #Displaying the name and the point value together in grading lists
  def formatted_name
    "#{name} - #{value} points"
  end

end