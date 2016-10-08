class CreateBusinesses < ActiveRecord::Migration
  def change
    create_table :businesses do |t|
      t.string :nit
      t.string :name
      t.string :address

      t.timestamps null: false
    end
  end
end
