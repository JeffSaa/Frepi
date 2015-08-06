class CreateStorePartners < ActiveRecord::Migration
  def change
    create_table :store_partners do |t|
      t.string :nit
      t.string :store_name
      t.string :manager_name
      t.string :manager_email
      t.string :manager_phone_number

      t.timestamps null: false
    end
  end
end
