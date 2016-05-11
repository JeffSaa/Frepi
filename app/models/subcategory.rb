class Subcategory < ActiveRecord::Base

  # Associations
  belongs_to :category
  has_many   :products, dependent: :destroy

  # Validations
  validates :name, :category, presence: true
  #validates :name, uniqueness: { scope: :category_id }
end
