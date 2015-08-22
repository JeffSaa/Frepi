class User < ActiveRecord::Base

  # Include default devise modules.
  # Exclude -> :rememberable, :omniauthable, :confirmatable
  devise  :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable

  include DeviseTokenAuth::Concerns::User

  # Variables
  #attr_accessor :password, :password_confirmation

  # Enumerators
  enum user_type: [:user, :administrator]

  # Associations
  has_many   :complaints
  has_many   :orders
  belongs_to :city

  # Validations
  validates :address, :user_type, :phone_number, :active, presence: true
  validates :latitude, :longitude, presence: true, numericality: true
  validates :user_type, inclusion: { in: %w(user administrator) }
  validates :identification, uniqueness: true, allow_nil: true
  validates :counter_orders, numericality: { only_integer: true }
  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }
  #validates :password, confirmation: true, on: :create
  #validates :password, confirmation: true, on: :update, if: :password
end
