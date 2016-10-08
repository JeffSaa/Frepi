class AddOrderToBills < ActiveRecord::Migration
  def change
    add_reference :bills, :order, index: true, foreign_key: true, default: 0
  end
end
