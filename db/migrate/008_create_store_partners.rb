class CreateStorePartners < ActiveRecord::Migration
  def change
    create_table :store_partners do |t|
      t.string :nit,         null: false
      t.string :store_name,  null: false
      t.string :logo,        null: false

      t.timestamps null: false
    end
  end
end
