class SubmissionFile < ActiveRecord::Base
  #include S3File

  attr_accessible :filename, :filepath, :submission_id

  belongs_to :submission

  validates :filename, presence: true,
                         length: { maximum: 50 }

  mount_uploader :filepath, SubmissionUploader

  # Note: older direct upload files have a url method that we must accomodate in the view
  # def url
  #   @url || filepath.url
  # end
end
