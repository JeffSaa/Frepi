class CreateOrdersProducts < ActiveRecord::Migration
  def change
    create_table :orders_products do |t|
      t.references :order,    index: true
      t.references :product,  index: true
      t.integer    :quantity, null: false, default: 0
      t.boolean    :acquired, null: false, default: true
      t.text       :comment

      t.timestamps null: false
    end
  end
end
