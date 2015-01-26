require 'spec_helper'

describe SubmissionFile, focus: true do
  before do
    @submission = build(:submission)
    @submission_file = build(:submission_file, submission: @submission)
  end

  subject { @submission_file }

  it { should respond_to("filename")}
  it { should respond_to("submission_id")}
  it { should respond_to("filepath")}

  it { should be_valid }

  describe "when filename is not present" do
    before { @submission_file.filename = nil }
    it { should_not be_valid }
  end

  describe "when filepath is not present" do
    pending "confirmation that we should fail out on this"
  end

  # describe "accepts a file in the file path" do
  #   @submission_file.filepath = fixture_file_upload('/files/test_image.jpeg', 'image/jpg')
  #   it { should_not be_valid }
  # end
end
