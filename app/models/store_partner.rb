class StorePartner < ActiveRecord::Base

  # Associations
  has_many :sucursals
  has_many :products, through: :sucursals
  has_many :subcategories, through: :products

  # Validations
  validates :name, :description, :logo, :nit, presence: true
end
