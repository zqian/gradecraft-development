class SubmissionFile < ActiveRecord::Base
  include S3File

  attr_accessible :file, :filename, :filepath, :submission_id

  belongs_to :submission

  validates :filename, presence: true, length: { maximum: 50 }

  mount_uploader :file, SubmissionUploader

  # Override S3File#url
  # Legacy submission files were handled by S3 direct upload and we stored their
  # Amazon key in the "filepath" field. Here we check if it has a value, and if
  # so we use this to retrieve our secure url. If not, we use the path supplied by
  # the carrierwave uploader
  def url
    return file.url if Rails.env == "development"

    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    if filepath.present?
      bucket.objects[CGI::unescape(filepath)].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    else
      bucket.objects[file.path].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    end
  end
end
