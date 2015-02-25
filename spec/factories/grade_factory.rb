FactoryGirl.define do
  factory :grade do
    raw_score { rand(200) + 100 }
    association :student, factory: :user
    association :assignment
    association :assignment_type
    association :course
  end
end
