class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :reference_code
      t.string  :name,          null: false
      t.decimal :store_price,   null: false
      t.decimal :frepi_price,   null: false
      t.string  :image,         null: false

      # Association
      t.references :subcategory, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end