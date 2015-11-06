class Order < ActiveRecord::Base

  # Enumerators, TODO: Changed to mayus
  STATUS = %w(RECEIVED DELIVERING DISPATCHED)
  enum status: STATUS

  # Associations
  belongs_to  :user, counter_cache: :counter_orders
  has_one     :shopper, through: :shoppers_order
  has_one     :shoppers_order
  has_many    :sucursals, through: :products
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_many    :orders_products
  has_many    :orders_schedules

  # Validations
  validates :user, :total_price, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :active, inclusion: { in: [true, false] }
  validates :total_price, numericality: true
  validates_datetime :delivery_time, allow_nil: true

  # Callbacks
  before_create :set_date
  before_save   :round_price

  # Methods
  # TODO: add schedules
  def self.buy(user, products)
    return false if not self.products_valid?(products)
    new_order = user.orders.new
    products.each do |product|
      new_order.add_products(product)
    end
    new_order
  end


  def add_products(product)
    order_products = self.orders_products.build(product_id: product[:id], quantity: product[:quantity].to_i)
    self.total_price += Product.find(product[:id]).frepi_price * product[:quantity].to_i
  end

  # TODO: increment counter cache when the order is active
  def update_products(products)
    Order.products_valid?(products)
    self.total_price = 0
    products.each do |product|
      if product[:quantity].to_i == 0
        self.orders_products.find_by(product_id: product[:id]).destroy
      else
        order_products = self.orders_products.find_by(product_id: product[:id])
        if order_products
          order_products.assign_attributes(quantity: product[:quantity].to_i)
          self.total_price += Product.find(product[:id]).frepi_price * product[:quantity].to_i
          order_products.save
        else
          self.add_products(product)
        end
      end
    end
    self
  end

  def delete_order
    self.active = false
    User.decrement_counter(:counter_orders, self.user.id)
    self.orders_products.each { |order| order.decrement_counter }
  end

  def self.products_valid?(products)
    products.each do |product|
      return false if not Product.exists?(product['id'])
    end
    true
  end
  # ---------------------- Private ---------------------------- #
  private

  def set_date
    self.date = DateTime.current
  end

  def reset_total_price
    self.total_price = 0
  end

  def round_price
    self.total_price.round(2)
  end
end
