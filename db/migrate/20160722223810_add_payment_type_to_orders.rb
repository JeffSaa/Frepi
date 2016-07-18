class AddPaymentTypeToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment, :integer, default: 0
  end
end
