FactoryGirl.define do
  factory :group do
    name 'Testing Group'
    association :assignment
  end
end