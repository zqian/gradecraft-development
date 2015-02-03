class AssignmentFile < ActiveRecord::Base
  include S3File

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  attr_accessible :filename, :filepath, :assignment_id

  belongs_to :assignment

  before_save :strip_path

  validates_presence_of :assignment_id

end
