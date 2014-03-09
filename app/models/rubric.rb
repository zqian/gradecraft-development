class Rubric < ActiveRecord::Base
  belongs_to :assignment
  has_many :metrics
  has_many :rubric_grades

  belongs_to :course
  has_many :assignment_rubrics, dependent: :destroy
  has_many :assignments, through: :assignment_rubrics
  
  validates :assignment


end
