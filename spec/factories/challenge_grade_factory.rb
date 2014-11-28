FactoryGirl.define do 
  factory :challenge_grade do 
    association :challenge
    association :team
    score '1000'
    feedback 'Well played'
  end
end