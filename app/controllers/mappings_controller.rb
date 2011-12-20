class MappingsController < ApplicationController
  before_filter :init_attachment, only: [:new, :create]
  before_filter :init_mappings, except: [:new, :create]
  
  def new
    @mapping = Mapping.new
  end
  
  def create
    @mapping = Mapping.new(params[:mapping])
    @mapping.company_id = current_company_id
    @mapping.user_id = current_user_id
    @mapping.attachments << @attachment
    if @mapping.save
      redirect_to new_attachment_import_url(@attachment)
    else
      render :new
    end
  end
  
  private
  
  def init_mappings
    @mappings = Mapping.by_c(current_company_id)
    @mapping = @mappings.find(params[:id]) if params[:id].present?
  end
  
  def init_attachment
    @attachment = Attachment.by_c(current_company_id).find(params[:attachment_id])
  end
end