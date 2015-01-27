FactoryGirl.define do
  factory :assignment_type do
    name 'Essays'
    association :course
    points_predictor_display 'Fixed'
  end
end
