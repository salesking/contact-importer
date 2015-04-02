require 'spec_helper'

describe Attachment do
  it { should belong_to(:mapping) }
  it { should have_many(:imports).dependent(:destroy) }

  ['filename', 'quote_char', 'encoding', 'disk_filename'].each do |attribute|
    it { should validate_presence_of(attribute)}
  end

  describe 'validations' do
    context 'col_sep' do
      let(:attachment) { build(:attachment) }
      before           {  }
      it 'is valid present' do
        attachment.col_sep = ','
        attachment.valid?
        expect(attachment.errors).to_not include(:col_sep)
      end

      it 'is invalid when blank' do
        attachment.col_sep = nil
        attachment.valid?
        expect(attachment.errors).to include(:col_sep)
      end

      # "\t" is blank,
      it 'is valid when blank, but \t' do
        attachment.col_sep = "\\t"
        attachment.valid?
        expect(attachment.errors).to_not include(:col_sep)
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
    File.exist?(file_path).should be false
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

  it 'set error for invalid csv' do
    invalid_attachment = create(:attachment, uploaded_data: file_upload('invalid_csv.csv'), col_sep: ',')
    expect(invalid_attachment.rows).to eq []
    expect(invalid_attachment.parse_error).to eq 'Missing or stray quote in line 3'
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
