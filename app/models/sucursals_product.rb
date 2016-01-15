class SucursalsProduct < ActiveRecord::Base

  # Associations
  belongs_to :sucursal
  belongs_to :product, dependent: :destroy

  # Validations
  validates :sucursal, :product, presence: true
end
