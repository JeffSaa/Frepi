class Api::V1::ApiController < ApplicationController

  # Api connection
  before_action :set_access_control_headers

  # Security
  before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, except: [:handle_options_request, :set_access_control_headers]
  skip_before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, if: :devise_controller?

  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, uid, access-token, client'
    headers['Access-Control-Expose-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, uid, access-token, client'
  end

  def require_administrator
    render( json: {errors: 'Authorized only for administrator.'} , status: :unauthorized) unless current_user.administrator
  end

  def administrador_supervisor
    unless (current_user.try('administrator') || current_supervisor)
      render( json: {errors: 'Authorized only for administrator and supervisors.'} , status: :unauthorized)
    end
  end
end
