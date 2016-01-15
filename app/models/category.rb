class Category < ActiveRecord::Base

  # Associations
  belongs_to :store_partner
  has_many   :subcategories, dependent: :destroy
  has_many   :products, through: :subcategories

  # Validations
  validates :name, presence: true
end
