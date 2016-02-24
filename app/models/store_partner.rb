class StorePartner < ActiveRecord::Base

  # Associations
  has_many :sucursals
  has_many :categories
  has_many :subcategories, through: :categories
  has_many :products, through: :sucursals

  # Validations
  validates :name, presence: true
end
