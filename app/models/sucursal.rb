class Sucursal < ActiveRecord::Base

  # Associations
  has_many   :orders
  has_many   :sucursals_products
  has_many   :products, through: :sucursals_products
  belongs_to :store_partner
end
