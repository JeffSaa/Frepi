class Subcategory < ActiveRecord::Base

  # Associations
  belongs_to :category
  has_many   :products

  # Validations
  validates :name, :category, presence: true
end
