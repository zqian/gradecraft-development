FactoryGirl.define do 
  factory :challenge_score_level do 
    association :challenge 
    name 'Unbeleivable'
    value '1000000'
  end
end