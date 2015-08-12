class SucursalsProduct < ActiveRecord::Base

  # Associations
  belongs_to :sucursal
  belongs_to :product

  # Validations
  validates :sucursal, :product, presence: true
end
