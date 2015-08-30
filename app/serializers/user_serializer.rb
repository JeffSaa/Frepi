class UserSerializer < ActiveModel::Serializer
  attributes  :id, :name, :last_name, :email, :identification, :address, :phone_number,
              :user_type, :active, :image, :counter_orders, :latitude, :longitude, :city_id,
              :provider, :uid, :nickname, :created_at, :updated_at
end
