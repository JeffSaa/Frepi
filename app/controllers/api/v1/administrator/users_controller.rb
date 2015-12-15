class Api::V1::Administrator::UsersController < Api::V1::ApiController
  skip_before_action :authenticate_supervisor!
  before_action :find_user, only: [:show, :update, :destroy]

  def index
    render json: User.where('id > 1')
  end

  def show
    render json: @user, root: 'user'
  end

  def create
    # TODO: Change city when the app grow
    user = User.new(user_params.merge(city_id: City.first.id, administrator: true))
    if user.save
      render(json: user, status: :created)
    else
      render(json: user.errors, status: :bad_request)
    end
  end

  # TODO: an administrator can modified other adminstrator!!
  def update
    unless @user.id == 1
      @user.assign_attributes(user_params)
      if @user.save
        render(json: @user)
      else
        render(json: @user.errors, status: :bad_request)
      end
    else
      render(json: { errors: 'the super administrator cannot be edit' })
    end
  end

  def destroy
    unless @user.id == 1
      @user.active = false
      @user.save
      render(json: @user)
    else
      render(json: { errors: 'the super administrator cannot be disable' })
    end
  end


  # ------------------- Private ------------------- #
  private
  def find_user
    begin
      @user = User.find(params[:id])
    rescue => e
      render(json: { error: e.message }, status: :not_found)
    end
  end

  def user_params
    params.permit(:name, :last_name, :email, :identification, :address, :phone_number, :image,
                  :latitude, :longitude, :password, :password_confirmation)
  end
end
