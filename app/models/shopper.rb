class Shopper < ActiveRecord::Base

  # Include default devise modules.
  # Exclude -> :rememberable, :confirmatable
  devise  :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Enumerators
  enum status: [:active, :idle]

  # Associations
  has_many :shoppers_orders
  has_many :shoppers_schedules
  has_many :orders, through: :shoppers_orders
  has_many :schedules,through: :shoppers_schedules

  # Validations
  validates :active, :phone_number, :status, presence: true
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :status, inclusion: { in: %w(active idle) }
  validates :identification, uniqueness: true, presence: true
  validates :email, :company_email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :first_name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }
end
