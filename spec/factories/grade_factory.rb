FactoryGirl.define do
  factory :grade do
    association :course
    association :assignment
    association :student, factory: :user
  end
end
