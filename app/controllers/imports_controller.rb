require 'csv'
class ImportsController < ApplicationController

  def show
    @import = Import.by_c(current_company_id).find(params[:id])
  end

  def new
    @import = Import.new :col_sep=>',', :quote_char=>'"'
  end

  def create
    @import = Import.new params[:import]
    @import.company_id = current_company_id
    @import.user_id = current_user_id
    # save mapping
    if @import.save
      conf = YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))
      app = SK::SDK::Oauth.new(conf)
      app.sub_domain = session['sub_domain']
      url = "#{app.sk_url}/api"
      @import.create_clients(url, session['access_token'])
      redirect_to @import
    else
      flash[:error] = I18n.t('imports.save_failed')
      render :action => "new"
    end
  end

  def destroy
    @import = Import.by_c(current_company_id).find(params[:id])
    if @import.destroy
      flash[:success] = t(:'imports.destroyed')
    else
      flash[:error] = t(:'imports.destroy_failed')
    end
    redirect_to imports_url
  end

  def index
    @imports = Import.by_c(current_company_id).order("created_at DESC")
  end

  # POST js uploader
  # TODO:
  # - check for headers if none use first data row
  # - only read first 100 lines
  # - hide headers/fields which are potentially empty see above
  # - find or construct a row with all data set, so we can show examples
  # - move to attachments/new
  # JSON
  def upload
    # save temp file, create attachment
    file = Attachment.new :uploaded_data => params[:file]
    file.company_id = current_company_id
    file.user_id = current_user_id
    file.save!
    # grab csv options
    opts = {:col_sep => params[:col_sep], :quote_char => params[:quote_char] }
#    puts opts.inspect
    data = CSV.read(file.full_filename, opts)
    # read json-schema
#    props = SK.send("#{params[:kind]}_fields")
    props = Sk.client_fields
    render :json => { :success => true,
                      :attachment_id => file.id,
                      :headers => data[0],
                      :data => data[1..10],
                      :schema => props
                    }, :status => :ok
  end

end