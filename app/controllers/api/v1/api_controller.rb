class Api::V1::ApiController < ApplicationController

  # Security
  before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, except: [:handle_options_request, :set_access_control_headers]
  skip_before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, if: :devise_controller?

  def require_administrator
    render( json: {errors: 'Authorized only for administrator.'} , status: :unauthorized) unless current_user.administrator
  end

  def administrador_supervisor
    unless (current_user.try('administrator') || current_supervisor)
      render( json: {errors: 'Authorized only for administrator and supervisors.'} , status: :unauthorized)
    end
  end
end
