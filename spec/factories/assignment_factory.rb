FactoryGirl.define do
  factory :assignment do
    association :course
    association :assignment_type
    name 'Essay 1'
    description 'Essay Description'
    point_total '100000'
    visible true 
    points_predictor_display 'Fixed'
  end
end
