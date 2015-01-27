FactoryGirl.define do
  factory :grade do
    raw_score { rand(200) + 100 }
  end
end
