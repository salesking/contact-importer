class ApplicationController < ActionController::Base
  protect_from_forgery
  
  rescue_from CanCan::AccessDenied do |exception|
    access_denied(exception.message)
  end

  protected
    
  def current_user
    return nil unless session['user_id'] && session['company_id'] && session['access_token']
    @current_user ||= User.new(user_id: session['user_id'], company_id: session['company_id'])
  end
  
  def access_denied(message)
    if session['sub_domain'] && Sk::APP.sub_domain == session['sub_domain'] # go to sk url if
      render :inline => "<script> top.location.href='#{Sk::APP.sk_url}'</script>"
    else
      redirect_to root_url, alert: message
    end
  end
end
