require "sk_sdk/oauth"
require "sk_sdk/signed_request"

class SessionsController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  skip_before_filter :login_required

  @@conf = YAML.load_file(Rails.root.join('config', 'salesking_app.yml'))
  SK_APP = SK::SDK::Oauth.new(@@conf)

  # POST Receives the oauth code from SalesKing, saves it to session
  # renders canvas haml
  def create
    r = SK::SDK::SignedRequest.new(params[:signed_request], SK_APP.secret)
    raise "invalid SalesKing app signed-request #{r.data.inspect}" unless r.valid?
    # always save and set subdomain
    SK_APP.sub_domain = session['sub_domain'] = r.data['sub_domain']
    if r.data['user_id'] # logged in
      # new session with access_token, user_id, sub_domain
      session['access_token'] = r.data['access_token']
      session['user_id'] = r.data['user_id']
      session['company_id'] = r.data['company_id']
      redirect_to imports_url
    else # must authorize redirect to oauth dialog
      render :inline => "<script> top.location.href='#{SK_APP.auth_dialog}'</script>"
    end
  end

  #GET coming back from auth dialog as redirect_url
  def new
    if params[:code] # coming back from auth dialog as redirect_url
      SK_APP.sub_domain = session['sub_domain'] 
      SK_APP.get_token(params[:code])
      #redirect to sk internal canvas page, where we are now authenticated
      render :inline => "<script> top.location.href='#{SK_APP.sk_canvas_url}'</script>"
    end
  end
end