FactoryGirl.define do
  factory :grade do
    course
    assignment
    association :student, factory: :user
  end
end
