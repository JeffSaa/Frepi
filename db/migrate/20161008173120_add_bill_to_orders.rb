class AddBillToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :bill, :reference
  end
end
