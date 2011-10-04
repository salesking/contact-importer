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

def user_login
  @request.session['access_token'] = 'abcdefg'
  @request.session['user_id'] = 'some-user_id'
  @request.session['company_id'] = 'a-company_id'
  @request.session['sub_domain'] = 'my-subdomain'
end

# Simulate a File Upload. Files reside in RAILS_ROOT/test/fixutes/files
# ==== Parameter
# filename<String>:: The file to upload
# ==== Returns
# <Object>::simulated file upload
def file_upload(filename)
  type = 'text/plain'
  file_path = Rails.root.join('spec/fixtures/', filename)
#  file = File.new(Rails.root.join('spec/fixtures/', filename), 'r')
  Rack::Test::UploadedFile.new(file_path, type)
#  ActionDispatch::Http::UploadedFile.new( :tempfile => file,
#                                          :filename => filename,
#                                          :type => type)
end

def response_to_json
  ActiveSupport::JSON.decode(response.body)
end