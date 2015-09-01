class Product < ActiveRecord::Base

  # Associations
  belongs_to :subcategory
  has_many   :orders_products
  has_many   :sucursals_products
  has_many   :orders, through: :orders_products
  has_many   :sucursals, through: :sucursals_products
  has_one    :category, through: :subcategory

  # Validations
  validates :name, :store_price, :frepi_price, :image, presence: true
  validates :store_price, :frepi_price, numericality: true
  validates :available, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :subcategory_id }
  validates :subcategory, presence: true
end
