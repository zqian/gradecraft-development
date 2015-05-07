FactoryGirl.define do
  factory :grade do
    association :course
    association :assignment
    association :student, factory: :user

    factory :scored_grade do
      raw_score { Faker::Number.number(5) }
      status "Released"
    end

    factory :unreleased_grade do
      score { Faker::Number.number(5) }
      status 'Graded'
      after(:create) do |grade|
        grade.assignment.update(release_necessary: true)
      end
    end

    factory :in_progress_grade do
      score { Faker::Number.number(5) }
      status 'In Progress'
    end
  end
end
