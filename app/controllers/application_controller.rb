class ApplicationController < ActionController::API

  include DeviseTokenAuth::Concerns::SetUserByToken

  # Api connection
  after_filter :set_access_control_headers
  #before_action :authenticate_user!

  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
  end

end
