class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.references :state, null: false, index: true, foreign_key: true
      t.string     :name,  null: false

      t.timestamps null: false
    end
  end
end
