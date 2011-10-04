require 'spec_helper'

describe ImportsController do
  render_views

  before :each do
    user_login
  end

  describe "GET 'index'" do

    it "should be successful without data" do
      get :index
      response.should be_success
    end

    it "should be successful" do
      i = Import.create :quote_char=>'"', :col_sep=>";"
      get :index
      response.should be_success
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "POST 'upload'" do

    it "should be successful" do
      lambda{
        post :upload, :file => file_upload('test1.csv'), :col_sep=>';', :quote_char=>'"'
      }.should change(Attachment, :count).by(1)
      response.should be_success
    end

    it "should return json" do
      post :upload, :file => file_upload('test1.csv'), :col_sep=>';', :quote_char=>'"'
      res = response_to_json
      res.keys.should include('success', 'attachment_id', 'headers', 'data', 'schema')
    end

    it "should return data rows in json" do
      post :upload, :file => file_upload('test1.csv'), :col_sep=>';', :quote_char=>'"'
      res = response_to_json
      res['data'].should ==  [[nil, nil, "", "Herr", nil, "Theo", "Heineman", nil, "Hubertstr. 205", "83620", "Feldkirchen", nil, nil, nil, "1721", "08063-98766543", " ", nil, "Messe", "Presse", nil, nil, nil, nil, nil, nil, nil, nil]]
    end
  end

end