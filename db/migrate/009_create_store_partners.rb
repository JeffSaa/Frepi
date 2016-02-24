class CreateStorePartners < ActiveRecord::Migration
  def change
    create_table :store_partners do |t|
      t.string :name,        null: false
      t.string :nit         
      t.string :logo  
      t.text   :description

      t.timestamps null: false
    end
  end
end
