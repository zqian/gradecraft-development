FactoryGirl.define do 
  factory :earned_badge do 
    association :badge
    association :student
  end
end