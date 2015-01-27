# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    name ""
    description ""
    close_date ""
    media ""
    thumbnail ""
    media_credit ""
    media_caption "MyString"
  end
end
