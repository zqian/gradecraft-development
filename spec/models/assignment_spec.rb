# spec/models/assignment_spec.rb
require 'spec_helper'

describe Assignment do

  before do
    @assignment = build(:assignment)
  end

  subject { @assignment }

  it { should respond_to("name")}
  it { should respond_to("description")}
  it { should respond_to("point_total")}
  it { should respond_to("due_at")}
  it { should respond_to("created_at")}
  it { should respond_to("updated_at")}
  it { should respond_to("level")}
  it { should respond_to("present")}
  it { should respond_to("course_id")}
  it { should respond_to("assignment_type_id")}
  it { should respond_to("grade_scheme_id")}
  it { should respond_to("grade_scope")}
  it { should respond_to("close_time")} #TODO delete and confirm, now "due_at"
  it { should respond_to("open_time")} #TODO delete and confirm, now "open_at"
  it { should respond_to("required")}
  it { should respond_to("accepts_submissions")}
  it { should respond_to("student_logged")}
  it { should respond_to("release_necessary")}
  it { should respond_to("open_at")}
  it { should respond_to("icon")}
  it { should respond_to("can_earn_multiple_times")}
  it { should respond_to("visible")}
  it { should respond_to("category_id")}
  it { should respond_to("resubmissions_allowed")}
  it { should respond_to("max_submissions")}
  it { should respond_to("accepts_submissions_until")}
  it { should respond_to("accepts_resubmissions_until")}
  it { should respond_to("grading_due_at")}
  it { should respond_to("role_necessary_for_release")}
  it { should respond_to("media")}
  it { should respond_to("thumbnail")}
  it { should respond_to("media_credit")}
  it { should respond_to("media_caption")}
  it { should respond_to("points_predictor_display")}
  it { should respond_to("notify_released")}
  it { should respond_to("mass_grade_type")}
  it { should respond_to("include_in_timeline")}
  it { should respond_to("include_in_predictor")}
  it { should respond_to("position")}
  it { should respond_to("include_in_to_do")}
  it { should respond_to("student_logged_button_text")}
  it { should respond_to("student_logged_revert_button_text")}
  it { should respond_to("use_rubric")}
  it { should respond_to("accepts_attachments")}
  it { should respond_to("accepts_text")}
  it { should respond_to("accepts_links")}

  it { should be_valid }

  #validations
  it "is valid with a name and assignment type" do
    expect(build(:assignment)).to be_valid
  end

  it "is invalid without a name" do
    expect(build(:assignment, name: nil)).to have(1).errors_on(:name)
  end

  it "is invalid without an assignment type" do
    expect(build(:assignment, assignment_type: nil)).to have(1).errors_on(:assignment_type_id)
  end

  it "has optional dates associated with it" do
    pending
    #TODO open_at, due_at, accepted_until business logic
    #TODO remove open_time, close_time
  end
end
