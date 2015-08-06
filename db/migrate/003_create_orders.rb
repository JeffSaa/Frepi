class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.boolean     :active,                    null: false, default: true
      t.integer     :status,                    null: false, default: 0
      t.datetime    :approximate_delivery_date

      # Associations
      t.references  :sucursal,                  null: false, index: true, foreign_key: true
      t.references  :user,                      null: false, index: true, foreign_key: true
      t.timestamps
    end
  end
end
