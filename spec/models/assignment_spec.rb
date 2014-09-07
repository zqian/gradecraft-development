# spec/models/assignment_spec.rb
require 'spec_helper'

describe Assignment do
  
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

end