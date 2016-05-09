class AddActiveToProducts < ActiveRecord::Migration
  def change
    add_column :products, :active,     :boolean, default: true
    add_column :products, :percentage, :decimal, precision: 5, scale: 2, default: 0
  end
end
