class SubmissionFile < ActiveRecord::Base
  include S3File

  attr_accessible :filename, :filepath, :submission_id

  belongs_to :submission

  validates :filename, presence: true,
                         length: { maximum: 50 }

  mount_uploader :filepath, SubmissionUploader

  def url
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    begin
      bucket.objects[CGI::unescape(filepath)].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    rescue Exception => e
      bucket.objects[CGI::unescape(filepath.url.split("/").last)].url_for(:read, :expires => 15 * 60).to_s #15 minutes
    end
  end
end
