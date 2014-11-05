module S3File

  def url
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    return bucket.objects[CGI::unescape(filepath)].url_for(:read, :expires => 15 * 60).to_s #15 minutes
  end

  def remove
    s3 = AWS::S3.new
    bucket = s3.buckets["gradecraft-#{Rails.env}"]
    bucket.objects[CGI::unescape(filepath)].delete
  end

  private

  def strip_path
    if filepath.present?
      filepath.slice! "/gradecraft-#{Rails.env}/"
      write_attribute(:filepath, filepath)
      # name = File.basename(filepath)
      # extension = File.extname(filepath)
      name = filepath.clone
      name.slice!(/.*\d\d.\d\d[%2F]*/).gsub(/[^0-9A-Za-z]/, '')
      write_attribute(:filename, name)

    end
  end
end
