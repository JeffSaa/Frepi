class Product < ActiveRecord::Base

  # External resources definitions
  include ActiveRecordHelper

  # scope
  scope :availables, -> { where(available: true, active: true) }
  scope :actives, -> { where(active: true) }

  # Associations
  belongs_to :subcategory
  has_many   :orders, through: :orders_products, dependent: :delete_all
  has_many   :sucursals, through: :sucursals_products
  has_one    :category, through: :subcategory, dependent: :delete
  has_many   :orders_products,  dependent: :destroy
  has_many   :sucursals_products, dependent: :delete_all

  # Validations
  validates :name, :store_price, :frepi_price, presence: true
  validates :store_price, :frepi_price, :percentage, numericality: true
  validates :available, :active, inclusion: { in: [true, false] }
  #validates :name, uniqueness: { scope: :subcategory_id }
  validates :reference_code, uniqueness: { scope: :subcategory_id }, allow_nil: true
  validates :subcategory, presence: true

  # Callbacks
  # before_validation :round_price
  before_save :format_attributes, :set_default_image

  private
    def round_price
      self.store_price = self.store_price.round(2).to_f
      self.frepi_price = self.frepi_price.round(2).to_f
    end

    def format_attributes
      self.escaped_name = attr_to_alpha(self.name)
    end

    def set_default_image
      self.image = 'http://s3-sa-east-1.amazonaws.com/frepi/products/KY2UFF7G4JJ2WDE2N90SM8LSLSCFAT3U' if self.image.blank?
      
    end
end
