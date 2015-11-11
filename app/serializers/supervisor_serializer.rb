class SupervisorSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :phone_numbre, :active, :address, :company_email, :personal_email, :image, :city_id
end
