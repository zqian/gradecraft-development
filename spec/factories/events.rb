# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    name ""
    description ""
    media ""
    thumbnail ""
    media_credit ""
    media_caption "MyString"
  end
end
