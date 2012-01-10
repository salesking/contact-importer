require 'spec_helper'

describe AttachmentsController do
  render_views

  context "for unauthenticated user" do
    describe "GET #index" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :index
      end
    end
    
    describe "GET #show" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :show, id: Factory(:attachment).id
      end
    end
    
    describe "GET #new" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        get :new
      end
    end
    
    describe "POST #create" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        post :create, attachment: {}
      end
    end
    
    describe "PUT #update" do
      it "triggers access_denied" do
        controller.should_receive(:access_denied)
        put :update, id: Factory(:attachment).id, attachment: {}
      end
    end
  end
  
  context "for authenticaned user" do
    before(:each) do
      @user_id = 'attachments-user'
      @company_id = 'attachments-company'
      user_login(user_id: @user_id, company_id: @company_id)
      @authorized_attachment = Factory(:attachment, company_id: @company_id)
      @unauthorized_attachment = Factory(:attachment, company_id: 'another-company')
    end

    describe "GET #index" do
      it "renders index template" do
        get :index
        response.should render_template(:index)
      end
      
      it "reveals attachments authorized by company" do
        get :index
        assigns[:attachments].should == [@authorized_attachment]
      end
    end
    
    describe "GET #show" do
      context "authorized" do
        it "renders show template" do
          get :show, id: @authorized_attachment.id
          response.should render_template(:show)
        end
        
        it "reveals requested attachment" do
          get :show, id: @authorized_attachment.id
          assigns[:attachment].should == @authorized_attachment
        end
      end
      
      context "unauthorized" do
        it "triggers access_denied" do
          controller.should_receive(:access_denied)
          get :show, id: @unauthorized_attachment
        end
      end
    end
    
    describe "GET #new" do
      it "renders new template" do
        get :new
        response.should render_template(:new)
      end
      
      it "reveals new attachment with default col_sep and quote_char" do
        get :new
        assigns[:attachment].should_not be_nil
        assigns[:attachment].col_sep.should_not be_nil
        assigns[:attachment].quote_char.should_not be_nil
      end
    end
    
    describe "POST #create" do
      it "creates new attachment" do
        lambda {
          post :create, file: file_upload('test1.csv'), col_sep: ';', quote_char: '"'
        }.should change(Attachment, :count).by(1)
      end
      
      it "reveals new attachment" do
        post :create, file: file_upload('test1.csv'), col_sep: ';', quote_char: '"'
        assigns[:attachment].should_not be_nil
      end
      
      it "sets attachment user_id" do
        post :create, file: file_upload('test1.csv'), col_sep: ';', quote_char: '"'
        assigns[:attachment].user_id.should == @user_id
      end
      
      it "sets attachment company_id" do
        post :create, file: file_upload('test1.csv'), col_sep: ';', quote_char: '"'
        assigns[:attachment].company_id.should == @company_id
      end
      
      it "renders successful json response" do
        post :create, file: file_upload('test1.csv'), col_sep: ';', quote_char: '"'
        response.content_type.should == "application/json"
        response.code.should == "200"
      end
    end
    
    describe "PUT #update" do
      context "unauthorized" do
        it "triggers access_denied" do
          controller.should_receive(:access_denied)
          put :update, id: @unauthorized_attachment, attachment: {col_sep: ';'}
        end
      end
      
      context "with valid parameters" do
        it "reveals requested attachment" do
          put :update, id: @authorized_attachment, attachment: {col_sep: '/'}
          assigns[:attachment].should == @authorized_attachment
        end
        
        it "updates attachment attributes" do
          put :update, id: @authorized_attachment, attachment: {col_sep: '/', quote_char: '^'}
          assigns[:attachment].col_sep.should == '/'
          assigns[:attachment].quote_char.should == '^'
        end
        
        it "redirects to new attachment mapping on html request" do
          put :update, id: @authorized_attachment, attachment: {col_sep: ';'}
          response.should redirect_to(new_attachment_mapping_url(@authorized_attachment))
        end
        
        it "reneders successful json response on js request" do
          put :update, id: @authorized_attachment, attachment: {col_sep: ';'}, format: 'js'
          response.code.should == "200"
        end
      end
      
      context "with invalid parameters" do
        it "reveals requested attachment" do
          put :update, id: @authorized_attachment, attachment: {col_sep: ''}
          assigns[:attachment].should == @authorized_attachment
        end
        
        it "renders new template on html request" do
          put :update, id: @authorized_attachment, attachment: {col_sep: ''}
          response.should render_template(:new)
        end
        
        it "reneders successful json response on js request" do
          put :update, id: @authorized_attachment, attachment: {col_sep: ''}, format: 'js'
          response.code.should == "200"
        end
      end
    end
  end
end
