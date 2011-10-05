require 'sk_sdk/oauth'
class DataRowsController < ApplicationController

  def destroy
    @data_row = Import.by_c(current_company_id).find(params[:id])
    if @data_row.destroy
      flash[:success] = I18n.t('imports.destroyed')
    else
      flash[:error] =  I18n.t('imports.destroy_failed')
    end
    redirect_to imports_url
  end

  def index
    @import = Import.by_c(current_company_id).find(params[:import_id])
    @data_rows = if params[:failed]
      @import.data_rows.failed
    else
      @import.data_rows
    end
  end
end