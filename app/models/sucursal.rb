class Sucursal < ActiveRecord::Base

  # Associations
  has_many   :orders
  has_many   :sucursals_products
  has_many   :products, through: :sucursals_products
  has_many   :subcategories, through: :products
  has_many   :categories, through: :subcategories
  belongs_to :store_partner

  # Validations
  validates :store_partner, :name, :address, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :name, uniqueness: { scope: :store_partner_id }

end
