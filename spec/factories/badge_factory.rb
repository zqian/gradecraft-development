FactoryGirl.define do
  factory :badge do
    course
    name Faker::Internet.domain_word
    point_total rand(100) + 20
  end
end
