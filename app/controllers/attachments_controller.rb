class AttachmentsController < ApplicationController
  before_filter :init_attachments, except: [:new, :create]
  
  def new
    @attachment = Attachment.new(col_sep: ',', quote_char: '"')
  end
  
  # TODO:
  # - check for headers if none use first data row
  # - hide headers/fields which are potentially empty
  # - find or construct a row with all data set, so we can show examples
  def create
    @attachment = Attachment.new(uploaded_data: params[:file], col_sep: params[:col_sep], quote_char: params[:quote_char])
    @attachment.company_id = current_company_id
    @attachment.user_id = current_user_id
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
      render :new
    end
  end
  
  private
  
  def init_attachments
    @attachments = Attachment.by_c(current_company_id).order("created_at DESC")
    @attachment = @attachments.find(params[:id]) if params[:id].present?
  end
end
