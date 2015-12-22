class CreateSucursals < ActiveRecord::Migration
  def change
    create_table :sucursals do |t|
      t.string  :name,                  null: false
      t.string  :manager_full_name
      t.string  :manager_email
      t.string  :manager_phone_number
      t.string  :phone_number
      t.string  :address,               null: false
      t.decimal :latitude,              precision: 15, scale: 10
      t.decimal :longitude,             precision: 15, scale: 10

      # Associations
      t.references :store_partner, null: false, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
