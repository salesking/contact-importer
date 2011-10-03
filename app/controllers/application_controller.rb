class ApplicationController < ActionController::Base
#  include AuthenticateSk
  protect_from_forgery
  before_filter :login_required

  protected

    def login_required
      session['access_token'] || access_denied
    end

    def access_denied
      SK_APP.sub_domain = session['sub_domain']
      render :inline => "<script> top.location.href='#{SK_APP.auth_dialog}'</script>"
    end
end
