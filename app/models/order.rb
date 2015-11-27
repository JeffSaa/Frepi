class Order < ActiveRecord::Base
  include ActiveModel::Serializers::JSON

  STATUS = %w(RECEIVED SHOPPING DELIVERING DISPATCHED)
  enum status: STATUS

  # Associations
  belongs_to  :user, counter_cache: :counter_orders
  has_many    :shopper, through: :shoppers_order
  has_many    :shoppers_order
  has_many    :sucursals, through: :products
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_many    :orders_products
  has_many    :orders_schedules

  # Validations
  validates :user, :total_price, :scheduled_date, :expiry_time, :arrival_time, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :active, inclusion: { in: [true, false] }
  validates :total_price, numericality: true
  validates_datetime :delivery_time, allow_nil: true
  validates_datetime :scheduled_date, :expiry_time
  validates_datetime :expiry_time, after: :arrival_time

  # Callbacks
  before_create :set_date
  before_save   :round_price

  # Methods
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


  def products_not_acquired(products)
    products ||= []
    products.each do |product|
      order_products = self.orders_products.where(product_id: product['id']).first
      if order_products
        order_products.update(acquired: product['acquired'])
      else
        return { error: "product #{product['id']} not found" }
      end
    end
    nil
  end

  def updated_shopper(shoppers)
    shoppers ||= []
    shoppers.each do |shopper|
      shopper_order = self.shoppers_order.where(shopper_id: shopper['old_shopper']).first
      if shopper_order
        shopper_order.shopper_id = shopper['new_shopper']
        shopper_order.save
        self.save
      else
        return { error: "shopper #{shopper['old_shopper']} not found" }
      end
    end
    nil
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

  def round_price
    self.total_price.round(2)
  end
end
