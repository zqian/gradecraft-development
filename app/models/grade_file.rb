class GradeFile < ActiveRecord::Base
  include S3File

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  attr_accessible :filename, :filepath, :grade_id

  belongs_to :grade

  before_save :strip_path

end
