class User < ActiveRecord::Base

  # Enumerators
  enum user_type: [:user, :administrator]

  # Associations
  has_many   :complaints
  has_many   :orders
  belongs_to :city

  # Validations
  validates :address, :user_type, :active, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :user_type, inclusion: { in: %w(user administrator) }
  validates :identification, uniqueness: true, allow_nil: true
  validates :email, presence: true, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }

end
