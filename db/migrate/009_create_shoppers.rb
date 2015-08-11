class CreateShoppers < ActiveRecord::Migration
  def change
    create_table :shoppers do |t|
      t.string  :name,              null: false
      t.string  :last_name,         null: false
      t.string  :identification,    null: false
      t.string  :phone_number,      null: false
      t.integer :status,            null: false
      t.string  :address
      t.string  :company_email
      t.string  :personal_email
      t.string  :image_url

      t.timestamps null: false
    end
  end
end
