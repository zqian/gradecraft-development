FactoryGirl.define do
  factory :badge do
    course
    name Faker::Internet.domain_word
    point_total { rand(200) + 100 }
    association :course
  end
end
