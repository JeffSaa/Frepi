class User < ActiveRecord::Base

  # Enumerators
  enum user_type: [:user, :administrator]

  # Associations
  has_many :complaints
  has_many :orders

  # Validations
end
