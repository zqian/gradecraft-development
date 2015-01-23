class SubmissionFile < ActiveRecord::Base
  #include S3File

  attr_accessible :filename, :filepath, :submission_id

  belongs_to :submission
  #before_save :strip_path

  mount_uploader :filepath, SubmissionUploader


  def url
    filepath.url
  end
end
