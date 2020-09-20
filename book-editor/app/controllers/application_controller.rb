class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_action :require_login
#  before_action :set_cache_buster
  protect_from_forgery with: :exception
  after_action :set_csrf_cookie_for_ng

#  def set_cache_buster
#    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
#    response.headers["Pragma"] = "no-cache"
#    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
#  end

  def set_csrf_cookie_for_ng
    cookies['XSRF-TOKEN'] = form_authenticity_token if protect_against_forgery?
  end

protected
    # In Rails 4.2 and above
    def verified_request?
        super || valid_authenticity_token?(session, request.headers['X-XSRF-TOKEN'])
    end

    # In Rails 4.1 and below
    def verified_request?
        super || form_authenticity_token == request.headers['X-XSRF-TOKEN']
    end
private
    def not_authenticated
        redirect_to login_path
    end
end
