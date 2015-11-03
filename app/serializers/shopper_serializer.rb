class ShopperSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :identification, :phone_number, :status, :email, :active, :address, :company_email, :image, :latitude, :longitude, :city_id, :provider, :uid, :created_at, :updated_at, :shopper_type
  has_many   :schedules
end
