class AssignmentGroup < ActiveRecord::Base

  attr_accessible :assignment, :assignment_id, :group, :group_id

  belongs_to :assignment
  validate :assignment, :presence => true
  belongs_to :group
  validate :group, :presence => true
  
  validates_uniqueness_of :assignment, { :scope => :group }

end