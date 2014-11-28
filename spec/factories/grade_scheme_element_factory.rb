FactoryGirl.define do 
  factory :grade_scheme_element do 
    association :course
    letter 'F'
    level 'Amoeba'
    low_range 0
    high_range 100
  end
end