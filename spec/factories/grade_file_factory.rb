FactoryGirl.define do
  factory :grade_file do
    assignment
    filename "test_file.rb"
    filepath { fixture_file('test_image.jpg', 'img/jpg') }
  end
end
