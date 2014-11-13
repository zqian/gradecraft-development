require "spec_helper"

describe "assignments/index" do

  context "with 2 assignments" do
    before(:each) do
      assign(:assignments, [
        stub_model(Assignment, :name => "Essay 1"),
        stub_model(Assignment, :name => "Blog Post")
      ])
      assign(:assignment_term, ["Assignments"])
    end

    it "displays both assignments" do
      render

      rendered.should contain("Essay 1")
      rendered.should contain("Blog Post")
    end
  end

end