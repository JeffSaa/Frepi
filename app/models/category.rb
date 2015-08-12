class Category < ActiveRecord::Base

  # Associations
  has_many :subcategories
  has_many :products, through: :subcategories

  # Validations
  validates :name, presence: true
end
