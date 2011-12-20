require 'spec_helper'

describe Mapping do
  it { should have_many(:mapping_elements).dependent(:destroy) }
  it { should have_many(:attachments).dependent(:nullify) }
end
