class Shopper < ActiveRecord::Base

  # Include default devise modules.
  # Exclude -> :rememberable, :confirmatable
  devise  :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  # radius for find orders in KM
  DISTANCE = 40000

  # Enumerators
  STATUS = %w(ACTIVE IDLE)
  TYPES = ['IN-STORE', 'DELIVERY']
  enum status: STATUS
  enum shopper_type: TYPES

  # Associations
  belongs_to :city
  has_many :shoppers_orders
  has_many :shoppers_schedules
  has_many :orders, through: :shoppers_orders
  has_many :schedules,through: :shoppers_schedules

  # Validations
  validates :active, :phone_number, :status, presence: true
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :status, inclusion: { in: STATUS }
  validates :shopper_type, inclusion: { in: TYPES }
  validates :identification, uniqueness: true, presence: true
  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :company_email, allow_nil: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :first_name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }

  def generate_token
    self.create_new_auth_token
  end
end
