class UserSerializer < ActiveModel::Serializer
  attributes  :id, :name, :last_name, :email, :identification, :address, :phone_number,
              :administrator, :active, :image, :counter_orders, :latitude, :longitude,
              :city_id, :loyal_costumer, :sign_in_count, :provider, :discount
end
