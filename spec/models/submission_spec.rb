require 'spec_helper'

describe Submission, focus: true do
  before do
    @submission = build(:submission)
  end

  subject { @submission }

  it { should respond_to("assignment_id")}
  it { should respond_to("student_id")}
  it { should respond_to("feedback")}
  it { should respond_to("comment")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("attachment_file_name")}
  it { should respond_to("attachment_content_type")}
  it { should respond_to("attachment_file_size")}
  it { should respond_to("attachment_updated_at")}
  it { should respond_to("link")}
  it { should respond_to("text_feedback")}
  it { should respond_to("text_comment")}
  it { should respond_to("creator_id")}
  it { should respond_to("group_id")}
  it { should respond_to("graded")}
  it { should respond_to("released_at")}
  it { should respond_to("task_id")}
  it { should respond_to("course_id")}
  it { should respond_to("assignment_type_id")}
  it { should respond_to("assignment_type")}

  it { should be_valid }

end
