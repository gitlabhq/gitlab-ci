require "spec_helper"

describe BuildsController do
  describe "routing" do

    it "routes to #index" do
      get("/builds").should route_to("builds#index")
    end

    it "routes to #new" do
      get("/builds/new").should route_to("builds#new")
    end

    it "routes to #show" do
      get("/builds/1").should route_to("builds#show", :id => "1")
    end

    it "routes to #edit" do
      get("/builds/1/edit").should route_to("builds#edit", :id => "1")
    end

    it "routes to #create" do
      post("/builds").should route_to("builds#create")
    end

    it "routes to #update" do
      put("/builds/1").should route_to("builds#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/builds/1").should route_to("builds#destroy", :id => "1")
    end

  end
end
