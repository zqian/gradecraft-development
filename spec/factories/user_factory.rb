FactoryGirl.define do
  factory :user do
<<<<<<< HEAD
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
=======
    username "AmazingGrace"
    sequence(:email) { |n| "rear_admiral#{n}@cobol.com" }
    first_name "Grace"
    last_name "Hopper"
>>>>>>> 510546b... file upload specs
  end
end
