require 'spec_helper'

describe Attachment do
  it { should belong_to(:mapping) }

  before :each do
    @attachment = Factory(:attachment)
  end

  it "should set filename and disk_filename" do
    @attachment.filename.should == 'test1.csv'
    @attachment.disk_filename.should_not be_empty
  end

  it "should remove file on destroy" do
    file_path = @attachment.full_filename
    @attachment.destroy
    File.exist?(file_path).should be_false
  end
  
  it "parses csv data" do
    @attachment.rows.size.should == 2
    @attachment.rows.first.size.should be > 1
  end
  
  it "reveals specified number of rows" do
    @attachment.rows(1).size.should == 1
  end
end