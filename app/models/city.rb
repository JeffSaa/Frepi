class City < ActiveRecord::Base

  # Associations
  belongs_to :state

  # Validations
  validates :state, :name, presence: true
  validates :name, uniqueness: true
end
