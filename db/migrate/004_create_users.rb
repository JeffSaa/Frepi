class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

      # User information
      t.string  :name,              null: false
      t.string  :last_name,         null: false
      t.string  :email,             null: false, unique: true
      t.string  :identification
      t.string  :address
      t.string  :phone_number
      t.boolean :administrator,     null: false, default: false
      t.boolean :active,            null: false, default: true
      t.string  :image
      t.integer :counter_orders,    null: false, default: 0

      # Extra information
      t.decimal :latitude,          precision: 15, scale: 10
      t.decimal :longitude,         precision: 15, scale: 10
      t.boolean :loyal_costumer,    default: false

      # Associations
      t.references :city,           index: true, foreign_key: true

      #------------------------- Devise ------------------------ #

      # Required
      t.string :provider, null: false, default: "email"
      t.string :uid, null: false, default: ""

      # Database authenticatable
      t.string :encrypted_password

      # Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      # Rememberable
      t.datetime :remember_created_at

      # Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      # Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      # Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # User Info
      t.string :nickname

      # Tokens
      t.text :tokens

      t.timestamps null: false
    end

    add_index :users, :email
    add_index :users, [:uid, :provider],     unique: true
    add_index :users, :reset_password_token, unique: true

  end
end
