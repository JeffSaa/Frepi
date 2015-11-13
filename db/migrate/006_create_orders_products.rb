class CreateOrdersProducts < ActiveRecord::Migration
  def change
    create_table :orders_products do |t|
      t.references :order,    index: true, foreign_key: true
      t.references :product,  index: true, foreign_key: true
      t.integer    :quantity, null: false, default: 0
      t.text       :comment

      t.timestamps null: false
    end
  end
end
