class CreateOrdersSchedules < ActiveRecord::Migration
  def change
    create_table :orders_schedules do |t|
      t.references :order,    index: true, foreign_key: true, null: false
      t.references :schedule, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
