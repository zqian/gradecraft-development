FactoryGirl.define do 
  factory :assignment_weight do
    association :student
    association :assignment
    weight 5
  end
end