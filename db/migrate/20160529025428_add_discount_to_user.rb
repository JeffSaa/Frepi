class AddDiscountToUser < ActiveRecord::Migration
  def change
    add_column :users, :discount, :integer, default: 0
    add_column :orders, :discount, :integer, default: 0
  end
end
