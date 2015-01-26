FactoryGirl.define do
  factory :submission_file do
    submission
    filename "test_file.rb"
    #filepath {fixture_file_upload('/files/test_image.jpeg', 'image/jpg')}
  end
end
