class Order < ActiveRecord::Base

  # Enumerators
  # TODO: Changed to mayus
  enum status: %w[received delivering dispatched]

  # Associations
  belongs_to  :user, counter_cache: :counter_orders
  belongs_to  :sucursal
  has_one     :shopper, through: :shoppers_order
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_one     :shoppers_order
  has_many    :orders_products
  has_many    :orders_schedules

  # Validations
  validates :user, :sucursal, :total_price, presence: true
  validates :status, inclusion: { in: %w(received delivering dispatched)}
  validates :active, inclusion: { in: [true, false] }
  validates :total_price, numericality: true
  validates_datetime :delivery_time, allow_nil: true


  # Callbacks
  before_create :set_date

  # Methods
  def buy(products)
    # TODO: roolback when the last product doesn't exist
    products.each do |product|
      order_products = self.orders_products.build(product_id: product[:id], quantity: product[:quantity])
      return false unless order_products.save
    end
    !products.blank?
  end

  def update_products(products)
    # TODO: increment counter cache when the order is active
    products.each do |product|
      if product[:quantity] == 0
        self.orders_products.find_by(product_id: product[:id]).destroy
      else
        order_products = self.orders_products.find_by(product_id: product[:id])
        if order_products
          order_products.assign_attributes(quantity: product[:quantity])
          order_products.save
        else
          self.buy(product)
        end
      end
    end
  end

  def delete_order
    self.active = false
    User.decrement_counter(:counter_orders, self.user.id)
    self.orders_products.each { |order| order.decrement_counter }
  end

  def set_date
    self.date = DateTime.current
  end
end
