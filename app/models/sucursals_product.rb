class SucursalsProduct < ActiveRecord::Base

  # Associations
  belongs_to :sucursal
  belongs_to :product
end
