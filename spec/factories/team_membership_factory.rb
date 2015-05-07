FactoryGirl.define do
  factory :team_membership do
    association :team
    association :student, factory: :user
  end
end
