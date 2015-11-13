class SupervisorSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :phone_number, :active, :address, :company_email, :email, :image, :city_id, :provider, :uid
end
