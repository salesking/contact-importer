require 'spec_helper'

describe DataRow do
  it { should belong_to(:import) }
end
