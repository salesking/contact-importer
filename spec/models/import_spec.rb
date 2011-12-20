require 'spec_helper'

describe Import do
  it { should have_many(:data_rows).dependent(:destroy) }
  it { should belong_to(:attachment) }
  
  it { should validate_presence_of(:attachment) }
  
  describe "data import" do
    before :each do
      @mapping = Factory(:mapping)
      Factory(:mapping_element, mapping: @mapping, source: 8, target: 'address.address1')
      Factory(:mapping_element, mapping: @mapping, source: 9, target: 'address.zip')
      Factory(:mapping_element, mapping: @mapping, source: 10, target: 'address.city')
      @attachment = Factory(:attachment, mapping: @mapping)
      @import = Factory.build(:import, attachment: @attachment)
      @client = stub_sk_client
    end

    it "should create data_rows" do
      @client.should_receive(:save).and_return(true)
      lambda { @import.save }.should change(DataRow, :count).by(1)
    end

    it "should create an address" do
      @client.should_receive(:save).and_return(true)
      @import.save
      @client.addresses[0].zip.should == '83620'
      @client.addresses[0].address1.should == 'Hubertstr. 205'
      @client.addresses[0].city.should == 'Feldkirchen'
    end

    it "should create failed data_rows" do
      @client.should_receive(:save).and_return(false)
      @client.errors.should_receive(:full_messages).and_return(['some error message'])
      lambda { @import.save }.should change(DataRow, :count).by(1)
      data_row = @import.data_rows.first
      data_row.sk_id.should be_nil
      data_row.log.should == 'some error message'
    end

    it "should be success if no rows failed" do
      @client.should_receive(:save).and_return(true)
      @client.should_receive(:id).and_return("some_uuid")
      @import.save
      @import.should be_success
    end
  end
end