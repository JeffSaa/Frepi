class AddIvaToProducts < ActiveRecord::Migration
  def change
    add_column :products, :iva, :decimal, precision: 5, scale: 2, default: 0
  end
end
