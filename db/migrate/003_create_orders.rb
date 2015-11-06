class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.boolean     :active,        null: false, default: true
      t.integer     :status,        null: false, default: 0
      t.decimal     :total_price,   null: false, default: 0, scale: 2, precision: 8
      t.datetime    :date,          null: false
      t.datetime    :delivery_time

      # Associations
      t.references  :user,          null: false, index: true, foreign_key: true
      t.timestamps
    end
  end
end
