# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay


  # Override the directory where uploaded files will be stored.
  # submission_file/course_name_id/assignment_name_id/student_name/file_name.ext
  def store_dir
    course = "#{model.submission.course.courseno}-#{model.submission.course.id}"
    assignment = "#{model.submission.assignment.name.gsub(/\s/, "_").downcase[0..20]}-#{model.submission.assignment.id}"
    student = "#{model.submission.student.last_name}-#{model.submission.student.first_name}"
    "uploads/#{course}/#{assignment}/#{student}"
  end

  # Override the filename of the uploaded files:
  def filename
    if original_filename.present?
      if model && model.read_attribute(mounted_as).present?
        model.read_attribute(mounted_as)
      else
        "#{tokenized_name}.#{file.extension}"
      end
    end
  end

  private

  def tokenized_name
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, "#{Time.now.to_i}_#{file.basename.gsub(/\s/, "_").downcase}")
  end
end
