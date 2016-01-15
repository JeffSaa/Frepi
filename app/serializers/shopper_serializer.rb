class ShopperSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :identification, :phone_number, :status, :email, :active, :address, :company_email, :image, :latitude, :longitude, :city_id, :created_at, :updated_at, :shopper_type, :taken_orders_count
end
