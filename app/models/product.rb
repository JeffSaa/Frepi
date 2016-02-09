class Product < ActiveRecord::Base

  # External resources definitions
  include ActiveRecordHelper

  # Associations
  belongs_to :subcategory
  has_many   :orders, through: :orders_products, dependent: :delete_all
  has_many   :sucursals, through: :sucursals_products
  has_one    :category, through: :subcategory, dependent: :delete
  has_many   :orders_products,  dependent: :destroy
  has_many   :sucursals_products, dependent: :delete_all

  # Validations
  validates :name, :store_price, :frepi_price, :image, presence: true
  validates :store_price, :frepi_price, numericality: true
  validates :available, inclusion: { in: [true, false] }
  validates :name, uniqueness: { scope: :subcategory_id }
  validates :reference_code, uniqueness: { scope: :subcategory_id }, allow_nil: true
  validates :subcategory, presence: true

  # Callbacks
  before_validation :round_price
  before_save :format_attributes

  private
  def round_price
    self.store_price = self.store_price.round(2).to_f
    self.frepi_price = self.frepi_price.round(2).to_f
  end

  def format_attributes
    self.escaped_name = attr_to_alpha(self.name)
  end
end
