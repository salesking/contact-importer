require 'spec_helper'
describe Sk do
  it "should read client fields" do
    ary = Sk.client_fields
    keys = ary.map{|i| i.keys[0] }
    keys.should include 'last_name', 'gender' #...
    keys.should_not include 'lock_version', 'addresses'
  end

  it "should read schema" do
    hsh = Sk.read_schema('client')
    hsh['title'].should == 'client'
  end
end