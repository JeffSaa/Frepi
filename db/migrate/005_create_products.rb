class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string  :reference_code
      t.string  :name
      t.decimal :store_price
      t.decimal :frepi_price
      t.string  :image

      t.timestamps null: false
    end
  end
end
