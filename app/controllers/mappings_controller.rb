class MappingsController < ApplicationController
  load_and_authorize_resource :attachment, only: [:new, :create]
  load_and_authorize_resource
  skip_load_resource only: [:create]

  def create
    @mapping = Mapping.new(mapping_params)
    @mapping.user = current_user
    @mapping.attachments << @attachment
    if @mapping.save
      redirect_to new_attachment_import_url(@attachment)
    else
      render :new
    end
  end

  private
  def mapping_params
    params.require(:mapping).permit(mapping_elements_attributes: [:id, :source, :target, :source, :conv_type, :conv_opts, :import_id])
  end
end