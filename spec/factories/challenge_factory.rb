FactoryGirl do 
  factory :challenge do 
    association :course
    name 'Epic Battle'
    visible true
    point_total '100000'
  end
end