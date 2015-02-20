class BadgeFile < ActiveRecord::Base
  include S3File

  attr_accessible :file, :filename, :filepath, :badge_id

  belongs_to :badge

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  def course
    badge.course
  end
end
