class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.boolean     :active,             null: false, default: true
      t.integer     :status,             null: false, default: 0
      t.integer     :total_price,        null: false, limit: 8
      t.datetime    :date,               null: false
      t.datetime    :scheduled_date,     null: false
      t.time        :arrival_time,       null: false
      t.time        :expiry_time,        null: false
      t.boolean     :notification_email, null: false, default: false
      t.string      :comment
      t.string      :address
      t.date        :shopping_at

      # Associations
      t.references  :user,          null: false, index: true

      t.timestamps
    end
  end
end
