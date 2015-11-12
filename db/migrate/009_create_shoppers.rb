class CreateShoppers < ActiveRecord::Migration
  def change
    create_table :shoppers do |t|

      # User Info
      t.string  :first_name,        null: false
      t.string  :last_name,         null: false
      t.string  :identification,    null: false
      t.string  :phone_number,      null: false
      t.integer :status,            null: false
      t.integer :shopper_type,      null: false
      t.string  :email,             null: false
      t.boolean :active,            null: false, default: true
      t.string  :address
      t.string  :company_email
      t.string  :image

      # Extra information
      t.decimal :latitude,          precision: 15, scale: 10
      t.decimal :longitude,         precision: 15, scale: 10

      # Associations
      t.references :city,           index: true, foreign_key: true

      t.timestamps
    end

    add_index :shoppers, :email
  end
end


