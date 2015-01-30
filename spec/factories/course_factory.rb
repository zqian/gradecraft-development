FactoryGirl.define do
  factory :course do
    name { Faker::Internet.domain_word }
    courseno { Faker::Internet.domain_word }
  end
end
