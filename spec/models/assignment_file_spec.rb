# spec/models/assignment_file_spec.rb
require 'spec_helper'

describe AssignmentFile do
  
  #validations
  it "is valid with an assignment" do 
    assignment_file = AssignmentFile.new(
      assignment_id: "1")
    expect(assignment_file).to be_valid
  end
  
  it "is invalid without an assignment" do 
    expect(AssignmentFile.new(assignment_id: nil)).to have(1).errors_on(:assignment_id)
  end

end