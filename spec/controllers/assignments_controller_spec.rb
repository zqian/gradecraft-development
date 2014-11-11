require 'spec_helper'

describe AssignmentsController do
  
  describe "#index" do
    it "populates an array of all assignments" do
      polsci = build(:course)
      essay = build(:assignment, course: polsci, name: "Essay")
      project = create(:assignment, course: polsci, name: "Game Design Project")
      get :index
      expect(assigns(:assignments)).to eq([project, essay])
    end

    it "renders the :index template" do 
      get :index    
      expect(response).to render_template :index
    end
  end

end