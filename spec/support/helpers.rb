
def user_login(params = {})
  @request.session['access_token'] = params[:access_token] || 'abcdefg'
  @request.session['user_id'] = params[:user_id] || 'some-user_id'
  @request.session['company_id'] = params[:company_id] || 'a-company_id'
  @request.session['sub_domain'] = params[:sub_domain] || 'my-subdomain'
end

def stub_sk_contact
  Sk.init('http://localhost', 'some-token')
  contact = Sk::Contact.new
  Sk::Contact.stub(:new).and_return(contact)
  contact.stub(:save).and_return(true)
  contact
end

def sk_config
  YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))[Rails.env]
end

def sk_url(sub_domain)
  sk_config['sk_url'].gsub('*', sub_domain)
end

def canvas_slug
  sk_config['canvas_slug']
end

# Simulate a File Upload. Files reside in RAILS_ROOT/test/fixutes/files
# ==== Parameter
# filename<String>:: The file to upload
# ==== Returns
# <Object>::simulated file upload
def file_upload(filename)
  type = 'text/plain'
  file_path = Rails.root.join('spec/fixtures/', filename)
  Rack::Test::UploadedFile.new(file_path, type)
end
