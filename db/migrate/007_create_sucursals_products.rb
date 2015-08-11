class CreateSucursalsProducts < ActiveRecord::Migration
  def change
    create_table :sucursals_products do |t|
      t.references :sucursal, index: true, foreign_key: true, null: false
      t.references :product,  index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
