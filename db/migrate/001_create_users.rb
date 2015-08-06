class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      # User Profile
      t.string  :name,              null: false
      t.string  :last_name,         null: false
      t.string  :email,             null: false
      t.string  :identification,    null: false
      t.string  :address,           null: false
      t.string  :phone_number,      null: false
      t.integer :user_type,         default: 0
      t.string  :state
      t.string  :country
      t.string  :image

      # Extra information
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps null: false
    end
  end
end
