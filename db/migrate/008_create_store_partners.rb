class CreateStorePartners < ActiveRecord::Migration
  def change
    create_table :store_partners do |t|
      t.string :nit,         null: false
      t.string :name,        null: false
      t.string :logo,        null: false
      t.text   :description, null: false

      t.timestamps null: false
    end
  end
end
