# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end


# Simulate a File Upload. Files reside in RAILS_ROOT/test/fixutes/files
# ==== Parameter
# filename<String>:: The file to upload
# ==== Returns
# <Object>::simulated file upload
def file_upload(filename)
  type = 'text/plain'
  file = File.new(Rails.root.join('spec/fixtures/', filename), 'r')
  ActionDispatch::Http::UploadedFile.new( :tempfile => file,
                                          :filename => filename,
                                          :type => type)
end