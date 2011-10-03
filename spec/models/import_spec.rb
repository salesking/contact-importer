require 'spec_helper'
describe Import do
  it "should not save without quote_char and col_sep" do
    obj = Import.new
    obj.save.should be_false
    obj.errors[:quote_char].should_not be_nil
    obj.errors[:col_sep].should_not be_nil
  end
end