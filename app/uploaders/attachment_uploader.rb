# encoding: utf-8

class AttachmentUploader < CarrierWave::Uploader::Base
  include ::CarrierWave::Backgrounder::Delay


  # NOTE: course, assignment, and student should be defined on the model in order to use them as subdirectories
  # example:
  # submission_file/course_name-id/assignment_name-id/student_name/timestamp_file_name.ext
  # assigment_file/course_name-id/assignment_name-id/timestamp_file_name.ext
  def store_dir
    course = "/#{model.course.courseno}-#{model.course.id}" if model.class.method_defined? :course
    assignment = "/#{model.assignment.name.gsub(/\s/, "_").downcase[0..20]}-#{model.assignment.id}" if model.class.method_defined? :assignment
    student = "/#{model.student.last_name}-#{model.student.first_name}" if model.class.method_defined? :student
    "uploads#{course}#{assignment}#{student}"
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
