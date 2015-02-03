class BadgeFile < ActiveRecord::Base
  include S3File

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  attr_accessible :filename, :filepath, :badge_id

  belongs_to :badge

  before_save :strip_path

end
