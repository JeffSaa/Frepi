class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :reference_code
      t.string  :name,          null: false
      t.string  :escaped_name,   null: false
      t.decimal :store_price,   null: false, scale: 2, precision: 8
      t.decimal :frepi_price,   null: false, scale: 2, precision: 8
      t.string  :image,         null: false
      t.boolean :available,     null: false, default: true
      t.integer :sales_count,   default: 0

      # Association
      t.references :subcategory, index: true

      t.timestamps null: false
    end
  end
end