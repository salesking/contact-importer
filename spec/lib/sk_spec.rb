require 'spec_helper'
describe Sk do
  it "should read contact fields" do
    ary = Sk.contact_fields
    keys = ary.map{|i| i.keys[0] }
    keys.should include 'last_name', 'gender', 'type' #...
    keys.should_not include 'lock_version', 'addresses'
  end

  it "should read schema" do
    hsh = Sk.read_schema('contact')
    hsh['title'].should == 'contact'
  end
end
