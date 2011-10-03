require "sk_sdk/oauth"
require "sk_sdk/signed_request"
module AuthenticateSk

  def self.included(base)
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    base.send :helper_method, :current_user,:current_company, :logged_in?
  end

  module ClassMethods
    # load settings
  end


  module InstanceMethods
    @@conf = YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))
    SK_APP = SK::SDK::Oauth.new(@@conf)

    protected

    def login_required
      logged_in? || access_denied
    end

    def logged_in?
      !!current_user
    end

    def current_company

    end

    def current_user
      @current_user ||= begin
       login_from_session || login_from_signed_request 
      end unless @current_user == false
    end

    def current_user=(data)
      if data
        session[:access_token] = data['access_token']
        session[:user_id] = data['user_id']
        session[:company_id] = data['company_id']
        @current_user = data['user_id']
#        @current_user = User.current = new_user
      else
        session[:user_id] = session[:company_id] = nil #User.current = 
        @current_user = false
      end
      @current_user
    end
      # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    def access_denied
#      redirect_uri = request.request_uri unless request.request_uri.include?('session')
#      redirect_to login_path(:redirect => redirect_uri)
      SK_APP.sub_domain = session['sub_domain']
      render :inline => "<script> top.location.href='#{SK_APP.auth_dialog}'</script>"
    end

    def login_from_session
      self.current_user = session[:user_id] if session[:user_id]
    end

    def login_from_signed_request
      if signed_request = params[:signed_request]
#        puts SK_APP.inspect
        r = SK::SDK::SignedRequest.new(signed_request, SK_APP.secret)
        raise "invalid SalesKing app signed-request #{r.data.inspect}" unless r.valid?
        # always save and set subdomain
        SK_APP.sub_domain = session['sub_domain'] = r.data['sub_domain']
        current_user = if r.data['user_id'] # logged in
          # new session with access_token, user_id, sub_domain
          session['access_token'] = r.data['access_token']
          session['user_id'] = r.data['user_id']
          session['company_id'] = r.data['company_id']
          session['sub_domain'] = r.data['sub_domain']
        else # must authorize redirect to oauth dialog
          
        end
      end
    end
    
  end # InstanceMethods
end #Module
