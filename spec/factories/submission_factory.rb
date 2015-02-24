FactoryGirl.define do
  factory :submission do
    association :assignment
    text_comment "needs a link, file, or text comment to be valid"
  end
end

