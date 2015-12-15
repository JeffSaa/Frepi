class Api::V1::ApiController < ApplicationController

  # Security
  before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, :is_active?, except: [:handle_options_request, :set_access_control_headers]
  skip_before_action :authenticate_user!, :authenticate_supervisor!, :require_administrator, :is_active?, if: :devise_controller?

  def require_administrator
    render(json: {errors: 'Authorized only for administrator.'} , status: :unauthorized) unless current_user.administrator
  end

  def administrador_supervisor
    unless current_user.try('administrator') || current_supervisor
      render(json: {errors: 'Authorized only for administrator and supervisors.'}, status: :unauthorized)
    end
  end

  # TODO: REFACTOR!
  def is_active?
    if user_signed_in? || supervisor_signed_in?
      render(json: {errors: 'you are disabled. please get in contact with the administrator'}, status: :unauthorized) unless current_user.try('active') || current_supervisor.try('active')
    end
  end
end
