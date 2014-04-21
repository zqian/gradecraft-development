class Rubric < ActiveRecord::Base
  attr_accessible :description, :name

  belongs_to :course
  has_many :assignment_rubrics, dependent: :destroy
  has_many :assignments, through: :assignment_rubrics

  validates_presence_of :course, :name, :description
end
