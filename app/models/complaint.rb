class Complaint < ActiveRecord::Base

  # Associations
  belongs_to :user

  # Validations
  validates :user, :subject, :message, presence: true
  validates :message, :subject, length: { minimum: 2 }
end
