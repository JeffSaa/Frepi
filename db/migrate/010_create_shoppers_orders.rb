class CreateShoppersOrders < ActiveRecord::Migration
  def change
    create_table :shoppers_orders do |t|
      t.references :shopper,       index: true, foreign_key: true
      t.references :order,         index: true, foreign_key: true
      t.datetime   :accepted_date

      t.timestamps null: false
    end
  end
end
