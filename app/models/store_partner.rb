class StorePartner < ActiveRecord::Base

  # Associations
  has_many :sucursals
  has_many :products, through: :sucursals
  has_many :subcategories, through: :products
  has_many :categories, through: :subcategories

  # Validations
  validates :name, :description, :logo, :nit, presence: true
end
