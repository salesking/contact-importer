require 'spec_helper'

describe ImportsController, 'logged out' do
  render_views

  it "should redirect to frontpage" do
    get :index
    response.should be_redirect
  end
  it "should redirect to salesking if subdomain is available" do
    @request.session['sub_domain'] = 'abc'
    get :index
    response.body.should == "<script> top.location.href='http://abc.salesking.local:3000'</script>"
  end
end

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
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!
      get :index
      response.should be_success
      assigns[:imports].length.should == 1
      assigns[:imports].should include import
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
  end

  describe "GET 'show'" do
    it "should be successful" do
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!
      
      get :show, :id=>import.id
      response.should be_success
      assigns[:import].should == import
    end
  end

  describe "POST 'create'" do

    it "should be successful" do
      Sk.init('http://localhost', 'token')
      client = Sk::Client.new
      Sk::Client.should_receive(:new).and_return(client)
      client.should_receive(:save).and_return(true)
      atm = Attachment.new :uploaded_data => file_upload('test1.csv')
      atm.company_id = @request.session['company_id']
      atm.save!
      opts = { :col_sep=>';', :quote_char=>'"',
               :kind => 'client',
               :attachment_id =>atm.id,
               :mappings_attributes => [
                 {:target => 'address.city', :source=>'8'},
                 {:target => 'last_name', :source=>'6'}
                ] }
      lambda{
        lambda{
          lambda{
            post :create, :import => opts
          }.should change(Mapping, :count).by(2)
        }.should change(DataRow, :count).by(1)
      }.should change(Import, :count).by(1)
      response.should be_redirect
      
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

  describe "DELETE 'import'" do

    it "should be successful" do
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!

      lambda{
        delete :destroy, :id => import.id
      }.should change(Import, :count).by(-1)
      response.should be_redirect
    end
  end

end