class User < ActiveRecord::Base

  # Include default devise modules.
  # Exclude -> :rememberable, :confirmatable
  devise  :database_authenticatable, :registerable,
          :recoverable, :trackable, :validatable, :omniauthable

  include DeviseTokenAuth::Concerns::User

  # Enumerators
  enum user_type: [:user, :administrator]

  # Associations
  has_many   :complaints
  has_many   :orders
  belongs_to :city

  # Validations
  validates :user_type, :active, presence: true
  validates :latitude, :longitude, numericality: true, allow_nil: true
  validates :user_type, inclusion: { in: %w(user administrator) }
  validates :identification, uniqueness: true, allow_nil: true
  validates :counter_orders, numericality: { only_integer: true }
  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/ }
  validates :name, :last_name, presence: true, length: { minimum: 3 }, format: { with: /\A[^0-9`!@#\$%\^&*+_=]+\z/ }

  # Methods
  def self.from_omniauth(auth)
    #provider: auth[:provider], uid: auth[:uid], name: auth[:name],                         last_name: auth[:last_name], image: auth[:image], email: auth[:email]
    user  = User.new(auth)
    user.errors
    user.save(validate: false)
    user
  end

end
