require "spec_helper"

describe TestReportsController do
  describe "routing" do

    it "routes to #index" do
      get("/test_reports").should route_to("test_reports#index")
    end

    it "routes to #new" do
      get("/test_reports/new").should route_to("test_reports#new")
    end

    it "routes to #show" do
      get("/test_reports/1").should route_to("test_reports#show", :id => "1")
    end

    it "routes to #edit" do
      get("/test_reports/1/edit").should route_to("test_reports#edit", :id => "1")
    end

    it "routes to #create" do
      post("/test_reports").should route_to("test_reports#create")
    end

    it "routes to #update" do
      put("/test_reports/1").should route_to("test_reports#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/test_reports/1").should route_to("test_reports#destroy", :id => "1")
    end

  end
end
