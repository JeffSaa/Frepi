class ProductsController < ActionController::Base
  before_action  :handle_options_request, :set_access_control_headers
  before_action  :require_admin

  def new
  end

  def create
    file = params[:file]
    if not file.blank?
      file = params[:file].read
      File.open(File.join(Rails.root, 'public', 'products.xlsx'), 'wb') { |f| f.write file }
      flash[:notice] = 'File updloaded! wait it is processing'
      system "RAILS_ENV=production rake products_utilities:upload_file &" if Rails.env.production?
      system "RAILS_ENV=development rake products_utilities:upload_file &"
    else
      flash[:notice] = 'You must select a valid file'
    end

    render 'products/new'
  end

  def logs
    lines = []
    File.open(File.join(Rails.root, 'public', 'products_log.txt'), "r") do |f|
      f.each_line do |line|
        lines << line
      end
    end
    render json: lines.to_json
  end



  def require_admin
    user = User.find_by(provider: params[:provider], uid: params[:uid])
    if !user || !user.valid_token?(params['access-token'], params['client']) || !user.administrator
      redirect_to new_session_path
      flash['notice'] = 'You must be logged in'
    end
  end

  # Methods for avoid cross origin problems
  def handle_options_request
    head(:ok) if request.request_method == "OPTIONS"
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, uid, access-token, client'
    headers['Access-Control-Expose-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, uid, access-token, client, Total-Count, Link, Location'
  end
end
