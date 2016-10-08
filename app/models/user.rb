class User < ActiveRecord::Base

  # Include default devise modules.
  # Exclude -> :rememberable, :confirmatable
  devise  :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  # scope
  scope :active, -> { where(active: true) }

  # Associations
  has_many   :complaints
  has_many   :orders
  has_many   :bills
  belongs_to :city

  # Validations
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :administrator, :active,  inclusion: { in: [true, false] }
  validates :identification, uniqueness: true, allow_nil: true
  validates :counter_orders, numericality: { only_integer: true }
  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }
  reverse_geocoded_by :latitude, :longitude

  # Callbacks
  before_create :free_discount


  # Methods
  def self.from_omniauth(auth)
    user  = User.new(auth)
    user.errors
    user.save(validate: false)
    user
  end

  # Discount for the first time
  def free_discount
    self.discount = 15_000
  end
end
