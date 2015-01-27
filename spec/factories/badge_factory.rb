FactoryGirl.define do
  factory :badge do
    name Faker::Internet.domain_word
    point_total rand(100) + 20
  end
end
