class Country < ActiveRecord::Base

  # Associations
  has_many :states
  has_many :cities, through: :states

  # Validations
  validates :name, uniqueness: true, presence: true
end
