require 'sk_sdk/oauth'

class ImportsController < ApplicationController
  before_filter :init_imports, except: [:new, :create]
  before_filter :init_attachment, only: [:new, :create]

  def new
    @import = Import.new(attachment: @attachment)
  end

  def create
    @import = Import.new(attachment: @attachment)
    @import.company_id = current_company_id
    @import.user_id = current_user_id

    if @import.save
      Sk::APP.sub_domain = session['sub_domain']
      Sk.init("#{Sk::APP.sk_url}/api", session['access_token'])
      redirect_to @import
    else
      render :action => "new"
    end
  end

  private
  
  def init_imports
    @imports = Import.by_c(current_company_id)
    @import = @imports.find(params[:id]) if params[:id].present?
  end
  
  def init_attachment
    @attachment = Attachment.by_c(current_company_id).find(params[:attachment_id])
  end
end