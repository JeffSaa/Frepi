class Distance < ActiveRecord::Base

  # Relations
  belongs_to :sucursal

  # Validation
  validates :distance, :sucursal_id, :destination_id, presence: true
end
