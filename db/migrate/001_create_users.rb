class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      # User information
      t.string  :name,              null: false
      t.string  :last_name,         null: false
      t.string  :email,             null: false
      t.string  :identification,    null: false
      t.string  :address,           null: false
      t.string  :phone_number,      null: false
      t.integer :user_type,         null: false, default: 0
      t.boolean :active,            null: false, default: true
      t.string  :image
      t.integer :counter_orders,    null: false, default: 0

      # Extra information
      t.decimal :latitude,          null: false, precision: 15, scale: 10
      t.decimal :longitude,         null: false, precision: 15, scale: 10

      # Associations
      t.references :city,           index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
