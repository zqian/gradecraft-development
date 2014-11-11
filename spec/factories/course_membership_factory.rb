FactoryGirl.define do
  factory :course_membership do 
    association :course
    association :user

    factory :admin do
      role "admin"
    end

    factory :professor do
      role "professor"
    end

    factory :gsi do
      role "gsi"
    end

    factory :student do
      role "student"
      score rand(0...1000000)
    end
  end
end