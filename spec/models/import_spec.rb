require 'spec_helper'
describe Import do
  it "should not save without quote_char and col_sep" do
    obj = Import.new
    obj.save.should be_false
    obj.errors[:quote_char].should_not be_nil
    obj.errors[:col_sep].should_not be_nil
  end
end

describe Import,'creating data' do

  before :each do
    @atm = Attachment.create :uploaded_data => file_upload('test1.csv')
    @import = Import.new :quote_char=>'"', :col_sep=>";",
                         :attachment_id => @atm.id
    @import.save
    Sk.init('http://localhost', 'some-token')
    @client = Sk::Client.new
    Sk::Client.should_receive(:new).and_return(@client)
  end

  it "should create data_rows" do
    @client.should_receive(:save).and_return(true)
    lambda{
      @import.create_clients('http://localhost', 'some-token')
    }.should change(DataRow, :count).by(1)
  end

  it "should create failed data_rows" do
    @client.should_receive(:save).and_return(false)
    @client.errors.should_receive(:full_messages).and_return('some error message')
    lambda{
      @import.create_clients('http://localhost', 'some-token')
    }.should change(DataRow, :count).by(1)
  end

  it "should be success" do
    @client.should_receive(:save).and_return(true)
    @client.should_receive(:id).and_return("some_uuid")
    @import.create_clients('http://localhost', 'some-token')
    @import.success?.should be_true
    @import.should be_success
  end
end