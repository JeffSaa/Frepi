class Product < ActiveRecord::Base

  # Associations
  has_many  :orders_products
  has_many  :sucursals_products
  has_many  :orders, through: :orders_products
  has_many  :sucursals, through: :sucursals_products

end
