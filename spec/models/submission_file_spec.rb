require 'spec_helper'

describe SubmissionFile, focus: true do
  before do
    @submission = build(:submission)
    @submission_file = @submission.submission_files.new
    #: {filepath: fixture_file_upload('/files/test_image.jpeg', 'image/jpg')})
  end

  subject { @submission_file }

  it { should respond_to("filename")}
  it { should respond_to("submission_id")}
  it { should respond_to("filepath")}

  it { should be_valid }

end
