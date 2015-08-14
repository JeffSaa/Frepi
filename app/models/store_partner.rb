class StorePartner < ActiveRecord::Base

  # Associations
  has_many :sucursals

  # Validations
  validates :name, :description, :logo, :nit, presence: true
end
