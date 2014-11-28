FactoryGirl.define do
  factory :assignment_score_level do
    association :assignment
    name 'Almost as Good As Your Neighbor'
    value '1000'
  end
end