require 'spec_helper'

describe SubmissionFile, focus: true do

  before do
    @submission = build(:submission)
    @submission_file = @submission.submission_files.new(filename: "test", filepath: fixture_file('test_image.jpg', 'img/jpg'))
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
    pending("shouldn't we fail?") do
      @submission_file.filepath = nil
      it { should_not be_valid }
    end
  end

  describe "as a dependency of the submission" do
    it "is saved when the parent submission is saved" do
      @submission.save!
      @submission_file.submission_id.should equal @submission.id
      @submission_file.new_record?.should be_false
    end

    it "is deleted when the parent submission is destroyed" do
      @submission.save!
      expect {@submission.destroy}.to change(SubmissionFile, :count).by(-1)
    end
  end

  it "accepts text files as well as images" do
    @submission_file.filepath = fixture_file('test_file.txt', 'txt')
    @submission.save!
    expect @submission_file.url.should =~ /\/uploads\/submission_file\/filepath\/#{@submission_file.id}\/\d+_test_file\.txt/
  end

  it "accepts multiple files" do
    @submission.submission_files.new(filename: "test", filepath: fixture_file('test_file.txt', 'img/jpg'))
    @submission.save!
    @submission.submission_files.count.should equal 2
  end

  it "has an accessible url" do
    @submission.save!
    expect @submission_file.url.should =~ /\/uploads\/submission_file\/filepath\/#{@submission_file.id}\/\d+_test_image\.jpg/
  end

  it "removes spaces from file names on save" do
    @submission_file.filepath = fixture_file('Spaces In Name.jpg', 'img/jpg')
    @submission.save!
    expect @submission_file.url.should =~ /\/uploads\/submission_file\/filepath\/#{@submission_file.id}\/\d+_spaces_in_name\.jpg/
  end
end
