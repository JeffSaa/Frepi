class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  # Security
  before_action :authenticate_user!
  before_action :require_administrator
  skip_before_action :authenticate_user!, :require_administrator, if: :devise_controller?

  # Api connection
  after_filter :set_access_control_headers

  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept'
  end

  def require_administrator
    render(json: { errors: 'Authorized only for administrator.' }, status: :unauthorized) if current_user.administrator?
  end

end
