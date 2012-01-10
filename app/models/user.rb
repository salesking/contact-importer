class User
  attr_reader :user_id, :company_id
  
  def initialize(params)
    @user_id = params[:user_id]
    @company_id = params[:company_id]
  end
end