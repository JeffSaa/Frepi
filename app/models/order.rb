class Order < ActiveRecord::Base
  include ActiveModel::Serializers::JSON

  STATUS = %w(RECEIVED SHOPPING DELIVERING DISPATCHED)
  enum status: STATUS

  # Scopes
  scope :in_progress, -> { where(active: true, notification_email: false).where('status >= 0 AND status <= 2') }
  scope :expiries, -> (datetime) { where('scheduled_date > ?', datetime ) }
  scope :created_between, lambda { |start_date, end_date| where("created_at >= ? AND created_at <= ?", start_date, end_date ) }

  # Associations
  belongs_to  :user, counter_cache: :counter_orders
  has_many    :shopper, through: :shoppers_order
  has_many    :sucursals, through: :products
  has_many    :products, through: :orders_products
  has_many    :schedules, through: :orders_schedules
  has_many    :shoppers_order,  dependent: :destroy
  has_many    :orders_products, dependent: :destroy
  has_many    :orders_schedules, dependent: :destroy

  # Validations
  validates :user, :total_price, :scheduled_date, :expiry_time, :arrival_time, presence: true
  validates :status, inclusion: { in: STATUS }
  validates :active, inclusion: { in: [true, false] }
  validates :total_price, numericality: true
  validates_time :expiry_time, on_or_after: :arrival_time
  validates_datetime :scheduled_date

  # Callbacks
  before_create :set_date
  before_save   :round_price, :set_shopping_at, :set_scheduled_date

  # Methods
  def buy(user, products)
    return false if not Order.products_valid?(products)
    products.each do |product|
      self.add_products(product)
    end
    self
  end


  def add_products(product)
    order_products = self.orders_products.build(product_id: product[:id], quantity: product[:quantity].to_i, comment: product[:comment])
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
    unless products.empty?
     self.total_price = 0
      products.each do |product|
        order_products = self.orders_products.where(product_id: product['id']).first
        if order_products
          acquired = product['acquired']
          order_products.update(acquired: product['acquired'])
          self.total_price +=  order_products.product.frepi_price * order_products.quantity if acquired
        else
          return { error: "product #{product['id']} not found" }
        end
      end
      self.save
    end
    nil
  end

  def updated_shopper(shoppers)
    shoppers ||= []
    shoppers.each do |shopper|
      shopper_order = self.shoppers_order.where(shopper_id: shopper['old_shopper']).first
      if shopper_order
        shopper_order.shopper.decrement!(:taken_orders_count)
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
    self.orders_products.each { |order| order.decrement_counter } if self.status == 'RECEIVED'
    self.save
  end

  def self.products_valid?(products)
    products.each do |product|
      return false if not Product.exists?(product[:id])
    end
    true
  end

  private
    def set_date
      self.date = DateTime.current
    end

    def round_price
      self.total_price.round(2)
    end

    def set_shopping_at
      if self.status_changed?(from: "RECEIVED", to: "SHOPPING") || self.status_changed?(from: nil, to: "SHOPPING")
        self.shopping_at = Date.current
      end
    end

    def set_scheduled_date
      self.scheduled_date = self.scheduled_date.change({ hour: 0}) + self.expiry_time.seconds_since_midnight.seconds
    end
end
