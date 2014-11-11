FactoryGirl.define do
  factory :assignment_group do
    association :assignment
    association :group
  end
end