class State < ActiveRecord::Base

  # Associations
  belongs_to :country
  has_many   :cities

  # Validations
  validates :country, :name, presence: true
  validates :name, uniqueness: true
end
