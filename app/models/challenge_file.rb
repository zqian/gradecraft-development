class ChallengeFile < ActiveRecord::Base
  include S3File

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  attr_accessible :filename, :filepath, :challenge_id

  belongs_to :challenge

  before_save :strip_path

end
