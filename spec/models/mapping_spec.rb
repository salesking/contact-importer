require 'spec_helper'

describe Mapping do
  before :each do
    @mapping = Factory(:mapping, :company_id => 'a company')
    Factory(:mapping_element, mapping: @mapping)
    Factory(:gender_mapping_element, mapping: @mapping)
    Factory(:birthday_mapping_element, mapping: @mapping)
  end
      
  it { should have_many(:mapping_elements).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:nullify) }
  
  describe ".by_company" do 
    it "includes mappings belongs to company" do 
      Mapping.by_company('a company').should include(@mapping) 
    end

    it "excludes mappings belongs to other company" do 
       another_mapping = Factory(:mapping, :company_id => 'another company')
       Mapping.by_company('a company').should_not include(another_mapping) 
    end 
  end

  describe ".with_fields" do 
    it "includes mappings with more than one mapping element defined" do 
      Mapping.with_fields.should include(@mapping) 
    end

    it "excludes mappings belongs to other company" do 
       another_mapping = Factory(:mapping, :company_id => 'another company')
       Mapping.with_fields.should_not include(another_mapping) 
    end 
  end
  
  describe '#title' do     
    it 'should return mapping details' do
      @mapping.title.should == '3 fields: organization, gender, and birthday'
    end
  end
end
