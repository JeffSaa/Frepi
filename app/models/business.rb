class Business < ActiveRecord::Base

  # Relationship
  has_many :bills

  # Validations
  validates :nit,   uniqueness: true
  validates :name,  presence: true
  validates :address, presence: true

  # scope sql
  scope :nit, -> (nit) { where("nit like ?", "#{nit}%") }
  scope :start_with, -> (name) { where("name like ?", "#{name}%") }

  # Callbacks
  before_save :format_attributes

  # Methods
  def format_attributes
    self.name.downcase!
  end
end
