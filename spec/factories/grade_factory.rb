FactoryGirl.define do
  factory :grade do
    association :course
    association :assignment
    association :student, factory: :user

    factory :scored_grade do
      raw_score { Faker::Number.number(5) }
      status "Released"
    end
  end
end
