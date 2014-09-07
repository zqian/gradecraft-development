FactoryGirl.define do
  factory :assignment do
    name 'Essay 1'
    association :assignment_type
    description 'Essay Description'
    point_total '100000'
    visible true 
    points_predictor_display 'Fixed'
  end
end
