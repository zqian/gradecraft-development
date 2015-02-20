FactoryGirl.define do
  factory :badge_file do
    badge
    filename "test_file.rb"
    filepath { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
