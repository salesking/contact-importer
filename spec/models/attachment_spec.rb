require 'spec_helper'

describe Attachment do
  it { should belong_to(:mapping) }
  it { should have_many(:imports).dependent(:destroy) }

  ['filename', 'quote_char', 'encoding', 'disk_filename'].each do |attribute|
    it { should validate_presence_of(attribute)}
  end

  describe 'validations' do
    context :col_sep do
      let(:attachment) { build(:attachment, col_sep: separator) }
      before           { attachment.valid? }
      subject          { attachment }
      context 'when present' do
        let(:separator) { ',' }
        its(:errors) { should_not include :col_sep }
      end

      context 'when blank' do
        let(:separator) { '' }
        its(:errors) { should include :col_sep }
      end

      # "\t" is blank,
      context 'when blank, but \t' do
        let(:separator) { "\\t" }
        its(:errors) { should_not include :col_sep }
      end
    end
  end

  before :each do
    @attachment = create(:attachment)
  end

  it 'should set filename and disk_filename' do
    @attachment.filename.should == 'test1.csv'
    @attachment.disk_filename.should_not be_empty
  end

  it 'should remove file on destroy' do
    file_path = @attachment.full_filename
    @attachment.destroy
    File.exist?(file_path).should be_false
  end

  it 'should silently ignore missing files on destroy' do
    file_path = @attachment.full_filename
    File.delete(file_path)
    lambda {@attachment.destroy}.should_not raise_error #(Errno::ENOENT)
  end

  it 'parses csv data' do
    @attachment.rows.size.should == 2
    @attachment.rows.first.size.should be > 1
  end

  it 'reveals specified number of rows' do
    @attachment.rows(1).size.should == 1
  end

  describe 'formats' do
    {'google_native_test_.csv' => 3, 'google_outlook_test.csv' => 3, 'test1.csv' => 2}.each do |csv_file, count|
      it "should able to read #{csv_file}" do
        attachment = create(:attachment, :uploaded_data => file_upload(csv_file))
        attachment.rows.first.size.should be > 1
        attachment.rows.size.should == count
      end
    end
  end

end
