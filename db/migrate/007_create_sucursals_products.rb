class CreateSucursalsProducts < ActiveRecord::Migration
  def change
    create_table :sucursals_products do |t|
      t.references :sucursal, index: true, foreign_key: true
      t.references :product,  index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
