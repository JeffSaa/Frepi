class AddBusinessPriceToProducts < ActiveRecord::Migration
  def change
    add_column :products, :business_price, :integer, default: 0
  end
end
