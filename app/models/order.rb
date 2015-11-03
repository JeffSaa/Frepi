class Order < ActiveRecord::Base

  # Enumerators, TODO: Changed to mayus
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
  validates :status, inclusion: { in: %w(received delivering dispatched) }
  validates :active, inclusion: { in: [true, false] }
  validates :total_price, numericality: true
  validates_datetime :delivery_time, allow_nil: true

  # Callbacks
  before_create :set_date
  before_update :reset_total_price
  before_save   :round_price

  # Methods
  def self.buy(user, order)
    # TODO: add schedules
    order.each do |sucursal|
      order = user.orders.new(sucursal_id: sucursal[:sucursal_id])
      order.add_products(sucursal[:products])
      order.save
    end
  end


  def add_products(products)
    # TODO: roolback when the last product doesn't exist
    products.each do |product|
      order_products = self.orders_products.build(product_id: product[:id], quantity: product[:quantity])
      calculate_total(order_products)
      order_products.save
    end
    !products.blank?
  end

  def update_products(products)
    # TODO: increment counter cache when the order is active, valid when the product don't exist
    products.each do |product|
      if product[:quantity] == 0
        orders_products = self.orders_products.find_by(product_id: product[:id]).destroy
      else
        order_products = self.orders_products.find_by(product_id: product[:id])
        if order_products
          order_products.assign_attributes(quantity: product[:quantity])
          order_products.save
          calculate_total(order_products)
        else
          self.add_products([product])
        end
      end
    end
  end

  def delete_order
    self.active = false
    User.decrement_counter(:counter_orders, self.user.id)
    self.orders_products.each { |order| order.decrement_counter }
  end

  # ---------------------- Private ---------------------------- #
  private

  def set_date
    self.date = DateTime.current
  end

  def calculate_total(order_product, sign = :increase)
    sign = sign == :increase ? '+' : '-'
    self.total_price = self.total_price.send(sign, order_product.product.frepi_price * order_product.quantity)
  end

  def reset_total_price
    self.total_price = 0
  end

  def round_price
    self.total_price.round(2)
  end
end
