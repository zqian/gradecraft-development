class UploadsController < ApplicationController
  def remove
    upload = params[:model].classify.constantize.find params[:upload_id]
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    bucket.objects[CGI::unescape(upload.filepath)].delete
    upload.destroy

    redirect_to :back
  end

  # Duplicate to the remove method, but manages both old and new
  # style submissions files. See SubmissionFile#url for more information
  def remove_submission_file
    upload = params[:model].classify.constantize.find params[:upload_id]
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    if Rails.env == "staging" || Rails.env == "production"
      if upload.filepath.present?
        bucket.objects[CGI::unescape(upload.filepath)].delete
      else
        bucket.objects[CGI::unescape(upload.file.path)].delete
      end
    end
    upload.destroy
    redirect_to :back
  end
end
