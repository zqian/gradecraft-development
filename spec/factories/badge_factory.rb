FactoryGirl.define do
  factory :badge do
    name Faker::Internet.domain_word
    point_total { rand(200) + 100 }
  end
end
