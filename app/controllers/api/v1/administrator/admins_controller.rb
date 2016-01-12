class Api::V1::Administrator::AdminsController < Api::V1::ApiController

  skip_before_action :authenticate_supervisor!

   def index
    if params[:page]
      @administrators = User.where("id > ? AND administrator = ?", 1, true).paginate(per_page: params[:per_page], page: params[:page])
      set_pagination_headers(:administrators)
      render json: @administrators
    else
      render json: { error: "param 'page' has not been found" }, status: :bad_request
    end
  end

end
