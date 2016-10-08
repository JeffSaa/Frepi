class AddBusinessToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :business, index: true, foreign_key: true, default: 0
  end
end
