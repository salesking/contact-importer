require 'spec_helper'

describe Attachment do
  it { should belong_to(:mapping) }
  it { should have_many(:imports).dependent(:destroy) }
  
  ['filename', 'col_sep', 'quote_char', 'encoding', 'disk_filename'].each do |attribute|
    it { should validate_presence_of(attribute)}
  end 
  
  [:col_sep, :quote_char, :uploaded_data, :encoding, :mapping_id].each do |attribute|
    it { should allow_mass_assignment_of(attribute) }
  end
     
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
  
  it "should silently ignore missing files on destroy" do
    file_path = @attachment.full_filename
    File.delete(file_path)
    lambda {@attachment.destroy}.should_not raise_error(Errno::ENOENT)
  end
  
  it "parses csv data" do
    @attachment.rows.size.should == 2
    @attachment.rows.first.size.should be > 1
  end
  
  it "reveals specified number of rows" do
    @attachment.rows(1).size.should == 1
  end
  
  describe "formats" do
    {'google_native_test_.csv' => 3, 'google_outlook_test.csv' => 3, 'test1.csv' => 2}.each do |csv_file, count|
      it "should able to read #{csv_file}" do
        attachment = Factory(:attachment, :uploaded_data => file_upload(csv_file))
        attachment.rows.first.size.should be > 1
        attachment.rows.size.should == count
      end
    end  
  end
  
end
