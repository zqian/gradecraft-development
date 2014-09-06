# spec/models/assignment_spec.rb
require 'spec_helper'

describe Assignment do
  
  #validations
  it "is valid with a name and assignment type" do 
    assignment = Assignment.new(
      name: "Essay 1", assignment_type_id: "1")
    expect(assignment).to be_valid
  end
  it "is invalid without a name" do 
    expect(Assignment.new(name: nil)).to have(1).errors_on(:name)
  end
  it "is invalid without an assignment type" do 
    expect(Assignment.new(assignment_type_id: nil)).to have(1).errors_on(:assignment_type_id)
  end

end