FactoryGirl.define do
  factory :assignment_type do
    name 'Essays'
    association :course
    points_predictor_display 'Fixed'

    factory :invisible_assignment do
       visible :false 
    end

    factory :unpredictable_assignment do
      include_in_predictor :false
    end
    
  end
end
