FactoryGirl.define do 
  factory :grade do 
    association :assignment
    association :course
    association :student
    score 999
    feedback 'Almost Perfect'
  end
end