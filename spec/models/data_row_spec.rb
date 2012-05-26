require 'spec_helper'

describe DataRow do
  it { should belong_to(:import) }

  describe "#populate_client" do
    before :each do
      @mapping = create(:mapping)
      @attachment = create(:attachment, mapping: @mapping)

      @import = build(:import, attachment: @attachment)
      @import.should_receive(:populate_data_rows).and_return(true)  #To avoid firing data_row create from after_save
      @import.save
      @client = stub_sk_client
    end

    context 'creating sk client record' do
      context 'successfully' do
        before :each do
          #TODO try moving these to factoris file. defining association with mapping in factory is not working at the moment.
          create(:mapping_element,  mapping: @mapping)
          create(:gender_mapping_element,  mapping: @mapping)
          create(:birthday_mapping_element,  mapping: @mapping)
          create(:fname_mapping_element, mapping: @mapping )
          create(:mapping_element, mapping: @mapping, source: 6, target: 'address.zip')
          create(:mapping_element, mapping: @mapping, source: 7, target: 'address.address1')
          create(:mapping_element, mapping: @mapping, source: 8, target: 'address.city')
          @csv_row = ["Test org", "T", "Male_user", "test@email.com", "Herr", "1980-01-10", '83620', 'Hubertstr. 205', 'Feldkirchen']
          @client.should_receive(:save).and_return(true)
          @client.should_receive(:id).and_return("some_uuid")
          @data_row = @import.data_rows.new(data: @csv_row)
          @data_row.save!
        end

        it "should save Client ID in corresponding data row" do
          @data_row.sk_id.should == 'some_uuid'
        end

        it "should have organization field value" do
          @client.organization.should == 'Test org'
        end

        it "should have converted enum field value" do
          @client.gender.should == 'male'
        end

        it "should have formatted date field value" do
          @client.birthday.should == '1980.01.10'
        end

        it "should join initial and first_name" do
          @client.first_name.should == 'T Male_user'
        end

        it "should create an address" do
          @client.addresses[0].zip.should == '83620'
          @client.addresses[0].address1.should == 'Hubertstr. 205'
          @client.addresses[0].city.should == 'Feldkirchen'
        end
      end #successfully

      context 'fails' do
        before :each do
          @csv_row = ["", "T", "Male_user", "test@email.com", "Herr", "1980-01-10", '83620', 'Hubertstr. 205', 'Feldkirchen']
          @client.should_receive(:save).and_return(false)
          @client.errors[:base] = 'Organisation or lastname must be present.'
          @data_row = @import.data_rows.new(data: @csv_row)
          @data_row.save!
        end

        it "should not save Client ID in corresponding data row" do
          @data_row.sk_id.should be_nil
        end

        it "should save failed row as source" do
          @data_row.source.should == @csv_row.to_csv(col_sep: @attachment.col_sep, quote_char: @attachment.quote_char)
        end

        it "should save error log returned from client" do
          @data_row.log.should == 'Organisation or lastname must be present.'
        end
      end #Fails

    end #creating sk client record

  end
end
