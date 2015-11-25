class CreateDistances < ActiveRecord::Migration
  def change
    create_table :distances do |t|
      t.references :sucursal,    null: false, index: true, foreign_key: true
      t.references :destination, null: false, index: true, foreign_key: true
      t.decimal    :distance,    null: false

      t.timestamps null: false
    end
  end
end
