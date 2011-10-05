require 'spec_helper'

describe DataRowsController do
  render_views

  before :each do
    user_login
  end

  describe "GET 'index'" do

    it "should be successful without data_rows" do
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!
      get :index, :import_id=>import.id
      response.should be_success
      assigns[:import].should == import
    end

    it "should be successful" do
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!
      row = import.data_rows.create!({:source=>'0',	:log=>'some failed log'})
      get :index, :import_id=>import.id
      assigns[:data_rows].length.should == 1
      assigns[:data_rows].should include(row)
      response.should be_success
    end
    
    it "should show failed" do
      import = Import.new :quote_char=>'"', :col_sep=>";"
      import.company_id = @request.session['company_id']
      import.save!
      row = import.data_rows.create!({:source=>'0',	:log=>'some failed log'})
      get :index, :import_id=>import.id, :failed=>true
      assigns[:data_rows].length.should == 1
      assigns[:data_rows].should include(row)
      response.should be_success
    end
  end

end