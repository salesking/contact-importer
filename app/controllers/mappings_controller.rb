class MappingsController < ApplicationController
  load_and_authorize_resource :attachment, only: [:new, :create]
  load_and_authorize_resource
  
  def create
    @mapping = Mapping.new(params[:mapping])
    @mapping.user = current_user
    @mapping.attachments << @attachment
    if @mapping.save
      redirect_to new_attachment_import_url(@attachment)
    else
      render :new
    end
  end
end