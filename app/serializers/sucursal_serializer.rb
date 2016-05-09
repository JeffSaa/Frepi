class SucursalSerializer < ActiveModel::Serializer
  attributes  :id, :name, :manager_full_name, :manager_email, :manager_phone_number, 
              :phone_number, :address, :latitude, :longitude, :store_partner_id,
              :created_at, :updated_at, :total_sold_frepi_price, :total_sold_store_price, 
              :earnings



end
