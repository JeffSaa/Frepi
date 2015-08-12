class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.references :country, index: true, foreign_key: true
      t.string     :name,    null: false

      t.timestamps null: false
    end
  end
end
