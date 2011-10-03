require 'spec_helper'
describe Sk do
  it "should read client fields" do
    obj = Sk.client_fields
    puts obj.inspect
#    obj.errors[:quote_char].should_not be_nil
  end
end