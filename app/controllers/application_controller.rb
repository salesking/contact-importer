class ApplicationController < ActionController::Base
#  include AuthenticateSk
  protect_from_forgery
  before_filter :login_required

  protected
    
    def current_company_id
      session['company_id']
    end
    def current_user_id
      session['user_id']
    end

    def login_required
      (session['user_id'] && session['user_id'] && session['access_token']) || access_denied
    end

    def access_denied
      SK_APP.sub_domain = session['sub_domain']
      render :inline => "<script> top.location.href='#{SK_APP.auth_dialog}'</script>"
    end
end
