class Api::V1::Administrator::AdminsController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!

  def index
    render json: User.where("id > ? AND  administrator = ? ", 1, true)
  end
end
