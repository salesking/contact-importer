require 'spec_helper'

describe DataRow do
  it { should belong_to(:import) }
 
  describe "#populate_client" do
    before :each do
      @mapping = Factory(:mapping)
      @attachment = Factory(:attachment, :uploaded_data => file_upload('valid_data.csv'), mapping: @mapping)
 
      @import = Factory.build(:import, attachment: @attachment)
      @import.should_receive(:populate_data_rows).and_return(true)  #To avoid firing data_row create
      @import.save
      @client = stub_sk_client
    end
    
    context 'creating sk client record' do
      before :each do
        Factory(:mapping_element,  mapping: @mapping)
        Factory(:gender_mapping_element,  mapping: @mapping)
        Factory(:birthday_mapping_element,  mapping: @mapping)
      end
      
      context 'successful' do
        before :each do
          @client.should_receive(:save).and_return(true)
          @client.should_receive(:id).and_return("some_uuid")
          @data_row = @import.data_rows.new(data: @attachment.rows[1])
          @data_row.save!
        end
        
        it "should save Client ID in corresponding data row" do
          @data_row.sk_id.should == "some_uuid"
        end
        
        it "should have converted enum field value" do
          @client.gender.should == "male"
        end
        
        it "should have formatted date field value" do
          @client.birthday.should == "1980.01.10"
        end
        
      end  
    end
 
  end
end
