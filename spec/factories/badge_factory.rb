FactoryGirl.define do 
  factory :badge do 
    name 'The One Badge to Rule Them All'
    visible true
    can_earn_multiple_times true
    point_total '500'
  end
end