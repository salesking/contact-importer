require 'spec_helper'

describe Import,'creating data' do

  before :each do
    @atm = Attachment.new :uploaded_data => file_upload('test1.csv')
  end

  it "should save" do
    lambda{
      @atm.save!
    }.should change(Attachment, :count).by(1)
  end

  it "should destroy file" do
    @atm.save!
    file_path = @atm.full_filename
    lambda{
      @atm.destroy
    }.should change(Attachment, :count).by(-1)
    File.exist?(file_path).should be_false
  end

  it "should set filename and disk_filename" do
    @atm.filename.should == 'test1.csv'
    @atm.disk_filename.should_not be_empty    
  end
end