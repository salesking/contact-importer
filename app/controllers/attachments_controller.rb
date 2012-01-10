class AttachmentsController < ApplicationController
  load_and_authorize_resource
  
  def new
    @attachment = Attachment.new(col_sep: ',', quote_char: '"')
  end
  
  # TODO:
  # - check for headers if none use first data row
  # - hide headers/fields which are potentially empty
  # - find or construct a row with all data set, so we can show examples
  def create
#    puts params[:file].tempfile.external_encoding.name
    @attachment = Attachment.new(uploaded_data: params[:file], col_sep: params[:col_sep], quote_char: params[:quote_char])
    @attachment.user = current_user
    @attachment.save!
    render json: {success: true, id: @attachment.id, rows: @attachment.rows(4)}, status: :ok
  end
  
  def update
    if @attachment.update_attributes(params[:attachment])
      respond_to do |format|
        format.html { redirect_to new_attachment_mapping_url(@attachment) }
        format.js { render json: {rows: @attachment.rows(4)}, status: :ok }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js { render json: {rows: {}}, status: :ok }
      end
    end
  end
end
