require 'spec_helper'

describe ImportsController, 'logged out' do
  render_views

  it "should redirect to frontpage" do
    get :index
    response.should be_redirect
  end
  
  it "should redirect to salesking if subdomain is available" do
    Sk::APP.sub_domain = @request.session['sub_domain'] = 'abc'
    get :index
    response.body.should == "<script> top.location.href='#{sk_url('abc')}'</script>"
  end
end

describe ImportsController do
  render_views

  before :each do
    user_login
    stub_sk_client
  end

  describe "GET 'index'" do

    it "should be successful without data" do
      get :index
      response.should be_success
      assigns[:imports].should == []
    end

    it "should reveal imports" do
      import = Factory(:import, company_id: @request.session['company_id'])
      get :index
      response.should be_success
      assigns[:imports].should == [import]
    end
  end

  describe "GET 'show'" do
    it "should reveal requested import" do
      import = Factory(:import, company_id: @request.session['company_id'])
      get :show, id: import.id
      response.should be_success
      assigns[:import].should == import
    end
  end
end