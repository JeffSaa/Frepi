class Business < ActiveRecord::Base

  # Relationship
  has_many :bills

  # Validations
  validates :nit,   uniqueness: true
  validates :name,  presence: true
  validates :address, presence: true

  # Callbacks
  before_save :format_attributes

  # Methods
  def format_attributes
    self.name.downcase!
  end
end
