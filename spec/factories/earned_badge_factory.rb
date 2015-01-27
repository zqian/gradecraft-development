FactoryGirl.define do
  factory :earned_badge do
    association :badge
    association :course
    association :student
  end
end
