class DataRowsController < ApplicationController

  def index
    @import = Import.by_c(current_company_id).find(params[:import_id])
    @data_rows = if params[:failed]
      @import.data_rows.failed
    else
      @import.data_rows
    end
  end
end