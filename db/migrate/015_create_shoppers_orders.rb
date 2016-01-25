class CreateShoppersOrders < ActiveRecord::Migration
  def change
    create_table :shoppers_orders do |t|
      t.references :shopper,       index: true
      t.references :order,         index: true
      t.datetime   :accepted_date

      t.timestamps null: false
    end
  end
end
