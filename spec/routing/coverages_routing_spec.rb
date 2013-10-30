require "spec_helper"

describe CoveragesController do
  describe "routing" do

    it "routes to #index" do
      get("/coverages").should route_to("coverages#index")
    end

    it "routes to #new" do
      get("/coverages/new").should route_to("coverages#new")
    end

    it "routes to #show" do
      get("/coverages/1").should route_to("coverages#show", :id => "1")
    end

    it "routes to #edit" do
      get("/coverages/1/edit").should route_to("coverages#edit", :id => "1")
    end

    it "routes to #create" do
      post("/coverages").should route_to("coverages#create")
    end

    it "routes to #update" do
      put("/coverages/1").should route_to("coverages#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/coverages/1").should route_to("coverages#destroy", :id => "1")
    end

  end
end
